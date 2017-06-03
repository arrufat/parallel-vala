namespace Parallel {
	public class ParArray<G> : Object {
		public unowned G[] data { get; set; }
		public uint num_threads { get; set; default = 0; }
		public uint start { get; set; default = 0; }
		public uint end { get; set; default = 0; }
		public bool exclusive { get; set; default = true; }
		public delegate void Processor<G> (ParArray<G> w);
		public Processor<G> function;

		/**
		 * Computes the range to use for current thread
		 *
		 * @param id thread id
		 * @param total the total number of elements in the original array
		 * @param num_threads the number of threads to use for processing
		 * @param first the index of the first element to process
		 * @param last the index of the last element to process
		 */
		private void get_range (int id, uint num_threads)
			requires (0 <= id < num_threads)
			ensures (this.start <= this.end)
			{
				var total = this.data.length;
				this.start = id * (total / num_threads);
				this.end = (id + 1) * (total / num_threads) - 1;
				if (id == num_threads - 1) this.end += total % num_threads;
				debug (@"Thread $(id) => start: $(this.start), end: $(this.end) (amount: $(this.end - this.start + 1))");
			}

		/**
		 * Dispatches the computations evenly accross the threads
		 */
		public void dispatch () {
			try {
				if (this.num_threads < 1) this.num_threads = get_num_processors ();
				if (this.data.length < this.num_threads) this.num_threads = this.data.length;
				var threads = new ThreadPool<ParArray<G>>.with_owned_data (
					(ThreadPoolFunc<ParArray<G>>) this.function,
					(int) this.num_threads, this.exclusive);
				for (var i = 0; i < this.num_threads; i++) {
					this.get_range (i, this.num_threads);
					var partial = new ParArray<G> ();
					partial.data = this.data;
					partial.num_threads = this.num_threads;
					partial.start = this.start;
					partial.end = this.end;
					threads.add (partial);
				}
			} catch (ThreadError e) {
				error (e.message);
			}
		}
	}
}
