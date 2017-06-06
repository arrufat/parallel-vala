// modules: gio-2.0 gdk-pixbuf-2.0
// sources: src/parallel.vala

using GLib;
using Parallel;

public static int size = 16;
public static bool fast = false;

public class Main : Object {
	private static bool version = false;
	[CCode (array_length = false, array_null_terminated = true)]
	private static string[] directory = null;
	private static int num_threads = 0;

	private const OptionEntry[] options = {
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref directory, "Directory with images to parse", "DIRECTORY" },
		{ "size", 's', 0, OptionArg.INT, ref size, "Filter out smaller images than this size (default: 16)", "INT" },
		{ "threads", 't', 0, OptionArg.INT, ref num_threads, "Use the given number of threads (default: all)", "INT" },
		{ "fast", 'f', 0, OptionArg.NONE, ref fast, "Use faster but less reliable mode", null },
		{ "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
		{ null } // list terminator
	};

	public static int main (string[] args) {

		var args_length = args.length;
		string help;
		/* parse the command line */
		try {
			var opt_context = new OptionContext ("- filter out bad images");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
			help = opt_context.get_help (true, null);
		} catch (OptionError e) {
			stdout.printf ("error: %s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 0;
		}

		if (args_length == 1) {
			print (help + "\n");
			return 0;
		}

		/* get the number of threads to use */
		if (num_threads < 1) {
			num_threads = (int) get_num_processors ();
		}

		/* get all files from directory */
		string file_name;
		var base_dir = directory[0];

		string[] files = {};
		try {
			var dir = Dir.open (base_dir);
			while ((file_name = dir.read_name ()) != null) {
				var file_path = Path.build_filename (base_dir, file_name);
				files += file_path;
			}
		} catch (FileError fe) {
			error (fe.message);
		}
		var num_files = files.length;
		message ("Found %u files", num_files);

		if (num_files < num_threads) {
			num_threads = (int) num_files;
		}
		message ("Using %d threads", num_threads);

		var par = new ParArray<string> ();
		par.data = files;
		par.function = filter_images;
		par.dispatch ();

		/* count the number of images found */
		var num_imgs = 0;
		foreach (var f in files) {
			if (f != null) {
				stdout.printf (f + "\n");
				num_imgs++;
			}
		}
		message ("Found %u images", num_imgs);

		return 0;
	}
}

void filter_images (ParArray<string> w) {
	var file_path = w.data[w.index];
	try {
		int width, height;
		if (fast) {
			Gdk.Pixbuf.get_file_info (file_path, out width, out height);
		} else {
			var img = new Gdk.Pixbuf.from_file (file_path);
			width = img.width;
			height = img.height;
		}
		if (width < size || height < size) {
			w.data[w.index] = null;
		}
	} catch (Error e) {
		w.data[w.index] = null;
		message ("i = %06u => %s (%s)", w.index, file_path, e.message);
	}
}
