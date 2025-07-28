#ifndef FIREBASE_CONFIG_H
#define FIREBASE_CONFIG_H

// Prevent macro redefinition warnings
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

// Disable specific warnings for Firebase
#ifdef _MSC_VER
#pragma warning(disable: 4996)  // 'strncpy': This function or variable may be unsafe
#pragma warning(disable: 4005)  // macro redefinition
#endif

#endif // FIREBASE_CONFIG_H 