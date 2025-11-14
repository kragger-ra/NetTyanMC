FROM eclipse-temurin:21-jre

# Устанавливаем рабочую директорию
WORKDIR /server

# Создаем необходимые директории
RUN mkdir -p /server/plugins /server/world_ai

# Устанавливаем переменные окружения
ENV JAVA_MEMORY=10G

# Порт сервера
EXPOSE 25566

# Запуск Paper с Aikar's flags
# Файлы монтируются через volumes в docker-compose.yml
CMD java -Xms${JAVA_MEMORY} -Xmx${JAVA_MEMORY} \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -jar paper.jar nogui
