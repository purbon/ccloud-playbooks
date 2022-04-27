#!/usr/bin/env python

def main(users):
    print("KafkaClient {\n")
    sasl_auth = "org.apache.kafka.common.security.plain.PlainLoginModule required \n username=\"{}\" \n password=\"{}\";\n"
    for key, value in users.items():
        sasl_string = sasl_auth.format(key, value)
        print(sasl_string)
    print("};\n")

    kafka_jaas = """ KafkaRest {
    org.eclipse.jetty.jaas.spi.PropertyFileLoginModule required
    debug="true"
    file="/etc/krest-auth/password.properties";
    };"""

    print(kafka_jaas)


if __name__ == "__main__":
    users = {
        "alice": "bob",
        "user": "pass"
    }
    main(users)
