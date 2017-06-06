using GLib;

namespace Parallel {
	public delegate void Processor<G> (ParArray<G> w);
	public class ParArray<G> : Object {
		public unowned G[] data { get; set; }
		public uint num_threads { get; set; default = 0; }
		public int index { get; set; default = 0; }
		public bool exclusive { get; set; default = true; }
		public Processor<G> function;

		public void dispatch () {
			try {
				if (this.num_threads < 1) this.num_threads = get_num_processors ();
				if (this.data.length < this.num_threads) this.num_threads = this.data.length;
				var threads = new ThreadPool<ParArray<G>>.with_owned_data (
					(ThreadPoolFunc<ParArray<G>>) this.function,
					(int) this.num_threads, this.exclusive);

				for (var i = 0; i < this.data.length; i++) {
					var partial = new ParArray<G> ();
					partial.data = this.data;
					partial.index = i;
					threads.add (partial);
				}
			} catch (ThreadError e) {
				error (e.message);
			}
		}
	}
}
