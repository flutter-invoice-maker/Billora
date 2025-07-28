# Firebase-specific CMake configuration
# This file handles Firebase plugin compilation issues

# Set compiler flags for Firebase plugins
if(MSVC)
    # Disable warnings that cause issues with Firebase
    add_compile_options(/wd4996)  # strncpy warnings
    add_compile_options(/wd4005)  # macro redefinition
    
    # Add preprocessor definitions
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    add_compile_definitions(_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS)
endif()

# Function to apply Firebase settings to a target
function(APPLY_FIREBASE_SETTINGS TARGET)
    if(MSVC)
        target_compile_options(${TARGET} PRIVATE /wd4996)
        target_compile_options(${TARGET} PRIVATE /wd4005)
        target_compile_definitions(${TARGET} PRIVATE _CRT_SECURE_NO_WARNINGS)
    endif()
endfunction() 