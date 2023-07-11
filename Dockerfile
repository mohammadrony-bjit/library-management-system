FROM openjdk:11

COPY target/*.jar libraryapp.jar

EXPOSE 8080

CMD ["java", "-jar", "/libraryapp.jar"]
