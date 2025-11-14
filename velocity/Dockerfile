FROM eclipse-temurin:21-jre

# Устанавливаем рабочую директорию
WORKDIR /server

# Создаем директории для данных
RUN mkdir -p /server/plugins

# Устанавливаем переменные окружения
ENV JAVA_MEMORY=1G

# Порт Velocity
EXPOSE 25570

# Запуск Velocity с оптимизированными флагами
# Файлы монтируются через volumes в docker-compose.yml
CMD java -Xms${JAVA_MEMORY} -Xmx${JAVA_MEMORY} \
    -XX:+UseG1GC \
    -XX:G1HeapRegionSize=4M \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+ParallelRefProcEnabled \
    -XX:+AlwaysPreTouch \
    -XX:MaxInlineLevel=15 \
    -jar velocity.jar
