export ALCOTEST_SHOW_ERRORS=true

opam pin add --no-action markup https://github.com/aantron/markup.ml.git\#input-stream

opam pin add --no-action tyxml .
opam pin add --no-action tyxml_ppx .

opam install -t --deps-only tyxml
opam install --verbose tyxml
opam remove --verbose tyxml
opam install camlp4
opam install -t --verbose tyxml
opam install -t --verbose tyxml_ppx

do_build_doc () {
  make wikidoc
  cp -Rf doc/manual-wiki/*.wiki ${MANUAL_SRC_DIR}
  cp -Rf _build/tyxml-api.wikidocdir/*.wiki ${API_DIR}
}

do_remove () {
  opam remove --verbose tyxml
}
