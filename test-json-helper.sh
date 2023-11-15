#!/bin/sh

OUTPUT=$($@)
jq -n --arg output "$OUTPUT" '{"output":$output}'
