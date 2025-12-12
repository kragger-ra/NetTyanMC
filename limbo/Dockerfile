FROM eclipse-temurin:21-jre

# Устанавливаем рабочую директорию
WORKDIR /server

# Создаем директории для данных
RUN mkdir -p /server/plugins

EXPOSE 25578

CMD ["java", "-Xms512M", "-Xmx1G", "-XX:+UseG1GC", "-XX:G1HeapRegionSize=4M", "-XX:+UnlockExperimentalVMOptions", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-jar", "limbo.jar", "--nogui"]
