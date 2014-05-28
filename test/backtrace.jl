bt = backtrace()
have_backtrace = false
for l in bt
    lkup = ccall(:jl_lookup_code_address, Any, (Ptr{Void},), l)
    if lkup[1] == :backtrace
        have_backtrace = true
        break
    end
end
@test have_backtrace

# Catching stack overflows
let
    f(x) = f(x+1)
    @test_throws StackOverflowError f(1)
end
