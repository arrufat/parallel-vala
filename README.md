# Parallel Vala

Parallel Vala is a class that eases parallel processing for Vala arrays.

Here's an example about how to compute the first 30 Fibonacci numbers in parallel:

``` vala
using GLib;
using Parallel;

int main (string [] args) {
	var array = new int[30];
	var par = new ParArray<int> ();
	par.data = array;
	par.num_threads = 4;
	par.function = compute_fibonacci;
	par.dispatch ();

	for (var i = 0; i < array.length; i++) {
		print ("Fibonacci (%d) = %u\n", i, array[i]);
	}

	return 0;
}

int fibonacci (int n) {
	if (n < 2) {
		return n;
	} else {
		return (fibonacci (n - 2) + fibonacci (n - 1));
	}
}

void compute_fibonacci (ParArray<int> p) {
	p.data[p.index] = fibonacci (p.index);
}
```

To use it in your code, simply add these lines to your `meson.build`:

``` meson

parallel = subproject('parallel')
parallel_dep = parallel.get_variable('parallel_dep')
```

Then, add `parallel_dep` to your dependencies array.
Finally, copy the [`parallel-vala.wrap`][wrap] to your `subprojects` folder.

[wrap]:https://raw.githubusercontent.com/arrufat/parallel-vala/master/parallel-vala.wrap
