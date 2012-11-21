#include <Ethernet.h>
#include <SPI.h>


byte mac[] = {0x2E, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
byte ip[] = {192, 168, 1, 177};
byte gateway[] = {192, 168, 10, 1};
byte netmask[] = {255, 255, 255, 0};

byte server[] = {173, 194, 32, 50}; // CrazyCoders

Client client(server, 80);

void setup()
{
  Ethernet.begin(mac, ip, gateway, netmask);
  Serial.begin(9600);

  delay(1000);

  Serial.println("connecting...");

  if (client.connect()) {
    Serial.println("connected");
    client.println("GET  HTTP/1.1");
    client.println("Host: ");
    client.println("Content-length: 0");
    client.println("User-Agent: Arduino/1.1");
    client.println();
  } else {
    Serial.println("connection failed");
    Serial.println(client.status(),DEC);
  }
}

void loop()
{
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    for(;;)
	;
  }
}
 
