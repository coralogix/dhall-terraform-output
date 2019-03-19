#!/usr/bin/env bats

setup() {
    mkdir -p ./gen
}

@test "help message" {
    run ./dhall-terraform-output
    [[ "${status}" -eq 0 ]]
}

@test "empty case" {
    ./dhall-terraform-output ./gen/type.dhall ./gen/out.dhall <<< '{}'
    [[ "$?" -eq 0 ]]
    dhall <<< './gen/out.dhall : ./gen/type.dhall'
    [[ "$?" -eq 0 ]]
    [[ $(cat ./gen/out.dhall) == '{=}' ]]
}

@test "Text, List Text, Natural" {
    ./dhall-terraform-output ./gen/type.dhall ./gen/out.dhall < ./test/input-example.json
    [[ "$?" -eq 0 ]]
    dhall <<< './gen/out.dhall : ./gen/type.dhall'
    [[ "$?" -eq 0 ]]
    dhall <<< '(./gen/out.dhall).aws_vpc_id : Text'
    [[ "$?" -eq 0 ]]
    dhall <<< '(./gen/out.dhall).aws_vpc_num_utility_subnets : Natural'
    [[ "$?" -eq 0 ]]
    dhall <<< '(./gen/out.dhall).aws_vpc_utility_subnet_azs : List Text'
    [[ "$?" -eq 0 ]]
}

@test "invalid input - not terraform formatted json" {
   run ./dhall-terraform-output ./gen/type.dhall ./gen/out.dhall <<< 'invalid'
   [[ "${status}" -ne 0 ]]
}

teardown() {
    rm -rf ./gen
}
