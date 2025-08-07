#!/bin/bash

export $(grep -v '^#' .devcontainer/.env | xargs)
devcontainer up --workspace-folder .
