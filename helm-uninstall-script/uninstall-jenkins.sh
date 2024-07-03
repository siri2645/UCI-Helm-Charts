#!/bin/bash
helm uninstall jenkins -n jenkins
kubectl delete ns jenkins


ALTER DATABASE jfrogdb OWNER TO postgres;
GRANT ALL PRIVILEGES ON DATABASE jfrogdb TO postgres;


