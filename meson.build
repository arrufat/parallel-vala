project('Parallel Vala', ['vala', 'c'],
    default_options: ['buildtype=release', 'default_library=shared'],
    version: '0.1.0')

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')

deps = [glib, gobject]

srcs = ['src/parallel.vala']

if get_option('shared_lib')
  libtype = 'shared_library'
else
  libtype = 'static_library'
endif

libparallel = build_target('parallel',
    sources: srcs,
    dependencies: deps,
    target_type: libtype,
    vala_header: 'parallel.h',
    vala_vapi: 'parallel.vapi',
    install_dir: [true, true, true],
    install: true)

parallel_dep = declare_dependency(
    include_directories: include_directories('.'),
    link_with: libparallel)

pkg = import('pkgconfig')
pkg.generate(
    libraries: libparallel,
    version: meson.project_version(),
    name: 'parallel',
    description: 'Ease parallel processing on native Vala arrays')

if get_option('enable_examples')
    gdk_pixbuf = dependency('gdk-pixbuf-2.0')
    executable('fibonacci',
        sources: [srcs, 'examples/fibonacci.vala'],
        dependencies: deps,
        install: false)

    executable('filter-images',
        sources: [srcs, 'examples/filter-images.vala'],
        dependencies: [deps, gdk_pixbuf],
        install: false)
endif
