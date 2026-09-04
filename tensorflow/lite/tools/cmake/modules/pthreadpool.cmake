if(TARGET pthreadpool OR pthreadpool_POPULATED)
  return()
endif()

include(OverridableFetchContent)

OverridableFetchContent_Declare(
  fxdiv
  URL "${TENSORFLOW_SOURCE_DIR}/externals/fxdiv.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/fxdiv"
)
OverridableFetchContent_GetProperties(fxdiv)
if(NOT fxdiv_POPULATED)
  OverridableFetchContent_Populate(fxdiv)
endif()
set(FXDIV_SOURCE_DIR "${CMAKE_BINARY_DIR}/fxdiv")

OverridableFetchContent_Declare(
  pthreadpool
  URL "${TENSORFLOW_SOURCE_DIR}/externals/pthreadpool.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/pthreadpool"
)

OverridableFetchContent_GetProperties(pthreadpool)
if(NOT pthreadpool)
  OverridableFetchContent_Populate(pthreadpool)
endif()
set(PTHREADPOOL_SOURCE_DIR "${CMAKE_BINARY_DIR}/pthreadpool")

include_directories(
  AFTER
  "${pthreadpool_SOURCE_DIR}/include"
)
