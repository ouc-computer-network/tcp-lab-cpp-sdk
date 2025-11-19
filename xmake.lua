set_project("tcp-lab-cpp-sdk")
set_version("0.1.0")

set_languages("cxx20")

add_rules("mode.debug", "mode.release")

add_includedirs("include", { public = true })

local function add_protocol_target(name, source)
    target(name)
        set_kind("shared")
        set_basename(name)
        add_files(source)
        if is_plat("macosx") then
            add_shflags("-undefined dynamic_lookup", { force = true })
        elseif is_plat("linux") then
            add_ldflags("-Wl,--unresolved-symbols=ignore-in-shared-libs", { force = true })
        elseif is_plat("windows") then
            if is_toolchain("msvc") then
                add_ldflags("/FORCE:UNRESOLVED", { force = true })
            else
                add_ldflags("-Wl,--unresolved-symbols=ignore-in-shared-libs", { force = true })
            end
            if is_mode("debug") then
                set_optimize("none")
                set_symbols("debug")
            end
        end
    target_end()
end

add_protocol_target("sender", "src/Sender.cpp")
add_protocol_target("receiver", "src/Receiver.cpp")

target("demo")
    set_kind("binary")
    add_files("src/main.cpp")
