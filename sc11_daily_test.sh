#!/bin/bash

function judge_ret() {
  if [[ $1 == 0 ]]; then
    echo -e "\033[32m Passed: $2 \033[0m"
    echo ""
  else
    echo -e "\033[31m Failed: $2 \033[0m"
    exit 1
  fi
  sleep 2
}

DAILY_TEST_DIR=$(dirname $(readlink -f "$0"))
DAILY_DEBS_DIR=$DAILY_TEST_DIR/ftp-$(date +'%Y-%m-%d')

pushd $DAILY_TEST_DIR

timeout 5m ./update_env.sh
judge_ret $? "update_env.sh"

# run your test scripts here
timeout 15m ./sail_test.sh
judge_ret $? "sail_test.sh"

# 15min to prevent too long download time
timeout 15m ./async_test.sh
judge_ret $? "async_test.sh"

# 10min to prevent too long download time
timeout 10m ./tgi_test.sh
judge_ret $? "tgi_test.sh"

popd

rm -rf $DAILY_DEBS_DIR