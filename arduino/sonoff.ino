#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>

const char* ssid = "MySSID";
const char* password = "MyPassword";

ESP8266WebServer server(80);

const int led = 13;
const int relay = 12;

String status;

void handleStatus() {
  server.send(200, "text/plain", status);
}

void handleOn() {
  status = "1\n";
  digitalWrite(relay, 1);
  server.send(200, "text/plain", status);
}

void handleOff() {
  status = "0\n";
  digitalWrite(relay, 0);
  server.send(200, "text/plain", status);
}

void handleNotFound(){
  String message = "Not found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET)?"GET":"POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i=0; i<server.args(); i++){
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  server.send(404, "text/plain", message);
}

void setup(void) {
  pinMode(led, OUTPUT);
  pinMode(relay, OUTPUT);
  digitalWrite(led, 1);
  digitalWrite(relay, 0);
  status = "0\n";
  
  WiFi.mode(WIFI_STA);
  
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  Serial.println("");

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  if (MDNS.begin("esp8266")) {
    Serial.println("MDNS responder started");
  }

  server.on("/Status", handleStatus);
  server.on("/On", handleOn);
  server.on("/Off", handleOff);

  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("HTTP server started");
  digitalWrite(led, 0);
}

void loop(void){
  server.handleClient();
}
