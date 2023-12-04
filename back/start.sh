#!/bin/bash
cd back;mix deps.get;mix ecto.reset;mix ecto.migrate;psql -h db -U postgres -d timemanager_dev;mix phx.server;