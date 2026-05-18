if(NOT WIN32)
    return()
endif()

add_executable(EyeMine WIN32 main.cpp)

set_target_properties(EyeMine PROPERTIES
    OUTPUT_NAME "LaunchMinecraftForEyeMine"
)

install(TARGETS EyeMine
    DESTINATION "."
    COMPONENT eyemine_launcher
    EXCLUDE_FROM_ALL
)
