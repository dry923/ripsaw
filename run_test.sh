#!/bin/bash
set -x

ci_dir=$1
ci_test=`echo $1 | sed 's/-/_/g'`

figlet $ci_test

cd $ci_dir

source tests/common.sh

wait_clean

# Test ci
if /bin/bash tests/$ci_test.sh > $ci_test.out 2>&1
then
  echo "$ci_dir: Successful"
  echo "$ci_dir: Successful" > ci_results
  echo "      <testcase classname=\"CI Results\" name=\"$ci_test\"/>" > results.xml
  echo "$ci_test | Pass" > results.markdown 
else
  echo "$ci_dir: Failed. Retrying once"

  echo "Cleaning up resources"
  wait_clean

  if /bin/bash tests/$ci_test.sh > $ci_test.out 2>&1
  then
    echo "$ci_dir: Successful"
    echo "$ci_dir: Successful" > ci_results
    echo "      <testcase classname=\"CI Results\" name=\"$ci_test\"/>" > results.xml
    echo "$ci_test | Pass" > results.markdown
  else
    echo "$ci_dir: Failed second attempt" 
    echo "$ci_dir: Failed" > ci_results
    echo "      <testcase classname=\"CI Results\" name=\"$ci_test\" status=\"$ci_test failed\">" > results.xml
    echo "         <failure message=\"$ci_test failed\" type=\"test failure\"/>
      </testcase>" >> results.xml
    echo "$ci_test | Fail" > results.markdown
    echo "Logs for "$ci_dir
    cat $ci_test.out
  fi
fi

wait_clean
