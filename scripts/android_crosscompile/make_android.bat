@echo off

set ANDROID_PLATFORM=21
set /p ANDROID_PLATFORM="Enter Android platform - Enter to use %ANDROID_PLATFORM%: "

set ANDROID_ABI=arm64-v8a
set /p ANDROID_ABI="Enter Android ABI ( armeabi-v7a, arm64-v8a , x86 , x86_64 ) - Enter to use %ANDROID_ABI% : "

set COMMON_CXX_FLAGS=-DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fexceptions -frtti -stdlib=libc++
set COMMON_C_FLAGS=-DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fexceptions

if %ANDROID_ABI% == armeabi-v7a (
  set CXX_FLAGS="%COMMON_CXX_FLAGS% -march=armv7-a -mthumb --target=armv7-none-linux-androideabi%ANDROID_PLATFORM%"
  set C_FLAGS="%COMMON_C_FLAGS% -march=armv7-a -mthumb --target=armv7-none-linux-androideabi%ANDROID_PLATFORM%"
)
if %ANDROID_ABI% == arm64-v8a (
  set CXX_FLAGS="%COMMON_CXX_FLAGS% -march=armv8-a --target=aarch64-none-linux-android%ANDROID_PLATFORM%"
  set C_FLAGS="%COMMON_C_FLAGS% -march=armv8-a --target=aarch64-none-linux-android%ANDROID_PLATFORM%"
)
if %ANDROID_ABI% == x86 (
  set CXX_FLAGS="%COMMON_CXX_FLAGS% --target=i686-none-linux-android%ANDROID_PLATFORM%"
  set C_FLAGS="%COMMON_C_FLAGS% --target=i686-none-linux-android%ANDROID_PLATFORM%"
)
if %ANDROID_ABI% == x86_64 (
  set CXX_FLAGS="%COMMON_CXX_FLAGS%"
  set C_FLAGS="%COMMON_C_FLAGS%"
)

set CMAKE_PATH="D:\Android\Sdk\cmake\3.22.1\bin\cmake.exe"

set ANDROID_NDK_PATH="D:\Android\Sdk\ndk\27.0.11718014"

set BUILD_FOLDER=build
rmdir /s /q %BUILD_FOLDER%
mkdir %BUILD_FOLDER%

%CMAKE_PATH% ^
  -G"Unix Makefiles" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK_PATH%\build\cmake\android.toolchain.cmake ^
  -DCMAKE_MAKE_PROGRAM=%ANDROID_NDK_PATH%\prebuilt\windows-x86_64\bin\make.exe ^
  -DANDROID_NDK=%ANDROID_NDK_PATH% ^
  -DOPERATING_SYSTEM="Android" ^
  -DANDROID_PLATFORM=%ANDROID_PLATFORM% ^
  -DANDROID_ABI=%ANDROID_ABI% ^
  -DASSIMP_ANDROID_JNIIOSYSTEM=ON ^
  -DASSIMP_BUILD_TESTS=OFF ^
  -DCMAKE_CXX_FLAGS=%CXX_FLAGS% ^
  -DMAKE_C_FLAGS=%C_FLAGS% ^
  -S "..\.." ^
  -B ".\%BUILD_FOLDER%\"

%CMAKE_PATH% --build ".\%BUILD_FOLDER%\"" -- -j 4"

@echo off
echo press anykey to continue... (XD)
pause>nul

set OUTPUT_FOLDER=.\output\
mkdir %OUTPUT_FOLDER%
mkdir "%OUTPUT_FOLDER%\lib\%ANDROID_ABI%"

copy "%BUILD_FOLDER%\bin\libassimp.so" "%OUTPUT_FOLDER%\lib\%ANDROID_ABI%\"
xcopy %BUILD_FOLDER%\include\assimp\ %OUTPUT_FOLDER%\include\assimp\ /y /s /e
xcopy ..\..\include\assimp\ %OUTPUT_FOLDER%\include\assimp\ /y /s /e

rmdir /s /q %BUILD_FOLDER%
