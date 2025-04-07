## Proxy examples for confluent cloud

```bash
kcat -b hostname:29092 \
-X security.protocol=sasl_ssl -X sasl.mechanisms=PLAIN \
-X sasl.username=<api-key>  -X sasl.password=<api-secret>  \
-L
```