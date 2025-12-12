FROM eclipse-temurin:21-jre

WORKDIR /server

# COPY . .

EXPOSE 25565 25577/udp

CMD ["java", "-Xms512M", "-Xmx1G", "-XX:+UseG1GC", "-XX:G1HeapRegionSize=4M", "-XX:+UnlockExperimentalVMOptions", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-jar", "velocity.jar"]