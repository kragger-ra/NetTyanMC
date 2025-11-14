FROM eclipse-temurin:21-jre

# Устанавливаем рабочую директорию
WORKDIR /server

# Создаем необходимые директории
RUN mkdir -p /server/plugins /server/world

# Устанавливаем переменные окружения
ENV JAVA_MEMORY=2G

# Порт сервера
EXPOSE 25569

# Запуск Paper с оптимизированными флагами для лобби
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
    -jar paper.jar nogui
