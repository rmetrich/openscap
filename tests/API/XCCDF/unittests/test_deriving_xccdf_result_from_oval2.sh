#!/bin/bash
. $builddir/tests/test_common.sh

set -e
set -o pipefail

touch not_executable

name=$(basename $0 .sh)

result=$(mktemp -t ${name}.out.XXXXXX)
stderr=$(mktemp -t ${name}.out.XXXXXX)

$OSCAP xccdf eval --results $result $srcdir/${name}.xccdf.xml 2> $stderr

echo "Stderr file = $stderr"
echo "Result file = $result"
[ -f $stderr ]; [ ! -s $stderr ]; rm $stderr

$OSCAP xccdf validate $result

assert_exists 2 '//rule-result'
assert_exists 2 '//rule-result/result'
assert_exists 2 '//rule-result/result[text()="pass"]'
assert_exists 2 '//rule-result/check'
assert_exists 2 '//rule-result/check[@system="http://oval.mitre.org/XMLSchema/oval-definitions-5"]'
assert_exists 1 '//rule-result/check[@negate="true"]'
assert_exists 2 '//rule-result/check/check-content-ref'
assert_exists 1 '//rule-result/check/check-content-ref[@href="test_deriving_xccdf_result_from_oval_fail.oval.xml"]'
assert_exists 1 '//rule-result/check/check-content-ref[@href="test_deriving_xccdf_result_from_oval_pass.oval.xml"]'
assert_exists 0 '//message'
assert_exists 0 '//check/@multi-check'
assert_exists 1 '//score'
assert_exists 1 '//score[text()="100.000000"]'

rm $result

rm not_executable
