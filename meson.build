project('Parallel Vala', ['vala', 'c'],
    default_options: ['buildtype=release', 'default_library=shared'],
    version: '0.1.0')

if get_option('buildtype') == 'release'
    if meson.get_compiler('c').has_argument('-march=native')
        add_global_arguments('-march=native', language: 'c')
    endif
endif

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gdk_pixbuf = dependency('gdk-pixbuf-2.0')

deps = [glib, gobject]

srcs = ['src/parallel.vala']

libparallel = library('parallel',
    sources: srcs,
    dependencies: deps,
    vala_header: 'parallel.h',
    vala_vapi: 'parallel.vapi',
    install: true)

executable('fibonacci',
    sources: [srcs, 'examples/fibonacci.vala'],
    dependencies: deps,
    install: false)

executable('filter-images',
    sources: [srcs, 'examples/filter-images.vala'],
    dependencies: [deps, gdk_pixbuf],
    install: false)
