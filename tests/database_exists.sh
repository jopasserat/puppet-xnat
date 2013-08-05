su xnat -c "psql -c \"SELECT 1 FROM pg_database WHERE datname='xnat';\" | grep \"1 row\"" > /dev/null
