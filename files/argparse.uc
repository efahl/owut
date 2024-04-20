//------------------------------------------------------------------------------
// argparse.uc - Argument Parser for ucode
// Copyright (c) 2024 Eric Fahlgren <eric.fahlgren@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only
// vim: set noexpandtab softtabstop=8 shiftwidth=8:
//------------------------------------------------------------------------------
// All uses of 'assert' in the argparse module indicate programming errors,
// and never user input errors.  If you define an argument incorrectly,
// an assertion will be raised, whereas if a user enters an incorrect
// command line, then 'usage' is called.
//
// To dump the list of actions, try this:
// $ ucode -p 'import { ArgActions } from "owut.argparse"; keys(ArgActions);'

export const ArgActions = {
// Static class of standard actions for arguments.
// All functions have the prototype:
//     fn(self, params)
// where
//     self = an ArgParser object
//     params = object with optional parameters, typically, but not restricted
//         to:
//         name  = option name
//         value = option value
//         msg   = any associated output message

	store: function(self, params) {
		// We don't flag multiple stores, last one wins.
		assert(params.name,  "'set' action requires an option name");
		assert(params.value, "'set' action requires a value");
		self.options[params.name] = params.value;
	},

	set: function(self, params) {
		assert(params.name, "'set' action requires an option name");
		assert(type(self.options[params.name]) == "bool", `missing default value for '${params.name}'?`);
		self.options[params.name] = true;
	},

	inc: function(self, params) {
		assert(params.name, "'inc' action requires an option name");
		assert(type(self.options[params.name]) == "int", `missing default value for '${params.name}'?`);
		self.options[params.name]++;
	},

	version: function(self, params) {
		self.show_version();
	},

	usage_short: function(self, params) {
		// Produce a short usage message.  'params' may contain 'prefix'
		// or 'suffix'.

		let shorts = [];
		for (let arg in self) {
			if (! arg.name) continue;

			if ("position" in arg) {
				push(shorts, uc(arg.name));
			}
			else {
				let name = arg.short || arg.long;
				// deal with "nargs" ...
				let v = arg.nargs > 0 ? ` ${uc(arg.name)}` : "";
				push(shorts, `[${name}${v}]`);
			}
		}

		if ("prefix" in params) printf("%s\n", params.prefix);
		printf(`Usage: ${self.program_string} %s\n`, join(" ", shorts));
		if ("suffix" in params) printf("%s\n", params.suffix);
	},

	usage: function(self, params) {
		self.show_version();

		// params: optional {msg}
		if (params?.msg) printf("\n%s\n", params.msg);
		
		if (self.prologue) print(self.prologue);
		this.usage_short(self, {prefix: ""});

		for (let arg in self) {
			if ("position" in arg) {
				printf("\n  %s - %s, must be one of:\n", uc(arg.name), arg.help);
				for (let n,v in arg.one_of) {
					printf("    %-8s - %s\n", n, v.help);
				}
				printf("\n");
			}
			else {
				let out = "";
				if (arg.short) out += arg.short;
				if (arg.long) {
					if (length(out)) out += "/";
					out += arg.long;
				}
				if (arg.nargs > 0) out += " " + uc(arg.name);
				printf("  %-15s - %s\n", out, arg.help);
			}
		}

		if (self.epilogue) print(self.epilogue);
	},
};

export const ArgParser = {
// Singleton class for a program's command line argument parsing.

	program_string: null,   // User-defined name of program.
	version_string: null,   // User-defined version string.
	prologue:       null,   // Text to put before argument list in usage.
	epilogue:       null,   // Text to put after argument list in usage.
	options:        null,   // Collected results from parsing.

	has_required:   false,  // Did the user specify any required arguments?

	show_version: function() {
		printf("%s\n", this.version_string ?? "no version string set");
	},

	set_prog_info: function(ver, prog) {
		// Allow user to set the version string, and optionally the
		// program string.
		proto(this).version_string = ver;
		proto(this).program_string = prog ?? split(sourcepath(1), "/")[-1];
	},

	set_bookends: function(prologue, epilogue) {
		proto(this).prologue = prologue;
		proto(this).epilogue = epilogue;
	},

	init: function() {
		// Build initial options table.
		// Could use a bunch of error checking added to verify
		// non-duplicate short and long, etc.

		proto(this).options = {};  // Build the result cache, populate with defaults.
		for (let i = 0, arg = this[i]; i < length(this); i++, arg = this[i]) {
			assert(arg.short || arg.long || "position" in arg,
				`arg definition must contain at least one of 'short', 'long' or 'position'\n  ${arg}`);

			arg = this[i] = proto(arg, ArgActions);  // Cast each arg to actions type.

			if (arg.name) {
				this.options[arg.name] = "default" in arg ? arg.default : null;
			}

			if (type(arg.action) == "string") {
				// Look up our canned actions.
				assert(arg.action in ArgActions, `action '${arg.action}' is not defined`);
				arg.action = ArgActions[arg.action];
			}

			if ("position" in arg) {
				// Positional arguments are required.
				proto(this).has_required = true;
			}
		}
	},

	get_arg: function(arg, position) {
		for (let opt in this) {
			if (position == opt.position) {
				if (arg in opt.one_of)
					return opt;
				ArgActions.usage(this, {msg: `ERROR: '${arg}' is not valid here, expected ${uc(opt.name)}`});
				exit(1);
			}
			if (arg in [opt.short, opt.long]) {
				return opt;
			}
		}
		return null;
	},

	parse: function(argv) {
		// Parse the argument vector.  If no value for 'argv' is
		// supplied, then use global ARGV.

		argv ??= ARGV;

		this.init();

		if (this.has_required && length(argv) == 0) {
			ArgActions.usage_short(this, {suffix: "Try '-h' for full help."});
			exit(1);
		}

		let iarg = 0;
		let narg = length(argv);
		while (iarg < narg) {
			let arg = argv[iarg];
			let opt = this.get_arg(arg, iarg);
			iarg++;

			if (! opt) {
				ArgActions.usage(this, {msg: `ERROR: '${arg}' is not a valid command or option`});
				exit(1);
			}

			let action_args = {};
			if ("name" in opt) {
				action_args.name = opt.name;
			}
			if ("position" in opt) {
				action_args.value = arg;
			}
			if ("nargs" in opt && opt.nargs > 0) {
				if (opt.nargs > narg-iarg) {
					ArgActions.usage(this, {msg: `ERROR: '${arg}' requires ${opt.nargs} values`});
					exit(1);
				}
					
				if (opt.nargs == 1) {
					action_args.value = argv[iarg];
				}
				else {
					action_args.value = slice(argv, iarg, iarg+opt.nargs);
				}
				iarg += opt.nargs;
			}

			opt.action(this, action_args);

			if ("auto_exit" in opt) {
				// The auto_exit parameter value is the  exit status code.
				exit(opt.auto_exit);
			}
		}

		return this.options;
	},
};

// argparse module provides a few canned option definitions.
export let DEFAULT_HELP    = { short: "-h", long: "--help",    action: "usage",   auto_exit: 1, help: "Show this message and quit." };
export let DEFAULT_VERSION = {              long: "--version", action: "version", auto_exit: 0, help: "Show the program version and terminate." };
