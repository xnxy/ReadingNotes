add_clang_executable(izzyrefactor
  IzzyRefactor.cpp
  )

target_link_libraries(izzyrefactor
  clangEdit clangTooling clangBasic clangAST clangASTMatchers)
