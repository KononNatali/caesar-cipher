FROM gradle:jdk8 AS build
COPY --chown=gradle:gradle . /app
WORKDIR /app
RUN gradle build --no-daemon 
#added lines
jdeps --list-deps /app/build/libs/*.jar > deps.txt

#end


FROM tomcat:jre8-alpine

EXPOSE 8080

RUN mkdir /app
COPY --from=build /app/build/libs/*.jar /app/caesar-cipher.jar
#added lines
COPY --from=build /home/gradle/src/deps.txt .

RUN MODULES=$(sed 's/,//g' deps.txt | tr '\n' ',' | sed 's/.$//'); \
    jlink --module-path $JAVA_HOME/jmods --add-modules $MODULES --output caesar-cipher
#end

ENTRYPOINT ["java","-jar","/app/caesar-cipher.jar"]