# Parallel Vala

Parallel Vala is a class that eases parallel processing for Vala arrays.

Here's an example about how to compute the first 30 Fibonacci numbers in parallel:

``` vala
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

void compute_fibonacci (ParArray<int> w) {
	for (var i = w.start; i <= w.end; i++) {
		w.data[(int) i] = fibonacci ((int) i);
	}
}
```
