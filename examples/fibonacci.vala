// sources: src/parallel.vala

using GLib;
using Parallel;

public static int first = 0;
public static int last = 10;

public class Main : Object {
	private static bool version = false;
	private static uint num_threads = 0;

	private const OptionEntry[] options = {
		{ "first", 'f', 0, OptionArg.INT, ref first, "First Fibonacci number to compute", "INT" },
		{ "last", 'l', 0, OptionArg.INT, ref last, "Last Fibonacci number to compute", "INT" },
		{ "threads", 't', 0, OptionArg.INT, ref num_threads, "Use the given number of threads", "INT" },
		{ "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
		{ null } // list terminator
	};

	public static int main (string[] args) {

		var args_length = args.length;
		string help;
		/* parse the command line */
		try {
			var opt_context = new OptionContext ("- compute Fibonacci numbers");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
			help = opt_context.get_help (true, null);
		} catch (OptionError e) {
			stdout.printf ("error: %s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 0;
		}

		var amount = last - first + 1;

		if (args_length == 1 || amount < 1) {
			print (help + "\n");
			return 0;
		}

		/* get the number of threads to use */
		if (num_threads < 1) {
			num_threads = get_num_processors ();
		}

		var array = new int[last - first + 1];
		var par = new ParArray<int> ();
		par.data = array;
		par.num_threads = num_threads;
		par.function = compute_fibonacci;
		par.dispatch ();

		for (var i = 0; i < array.length; i++) {
			print ("Fibonacci (%d) = %u\n", i + first, array[i]);
		}

		return 0;
	}
}

int fibonacci (int n) {
	if (n < 2) {
		return n;
	} else {
		return (fibonacci (n - 2) + fibonacci (n - 1));
	}
}

void compute_fibonacci (ParArray<int> w) {
		w.data[w.index] = fibonacci (first + w.index);
}
