using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libpyhanabi"], :libpyhanabi),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/findmyway/HanabiBuilder/releases/download/v0.1.1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Hanabi.v0.1.1.aarch64-linux-gnu.tar.gz", "6ad361d3c89f06a6a06dbb91a16e85eb1fd66225c78fb74ef2d66398b0549384"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Hanabi.v0.1.1.aarch64-linux-musl.tar.gz", "70217948268968dbeb7ab994d4152458822ba3941ed3a63f7010c689bf9067e0"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Hanabi.v0.1.1.arm-linux-gnueabihf.tar.gz", "0465fe0415876587f6c08f8316f5d2e35b1fed235b894a62440f351bf2412c24"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Hanabi.v0.1.1.arm-linux-musleabihf.tar.gz", "361d6466eb3be67ac09307b10461b10ec3315f250df857e130a0712f78cbf7a3"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Hanabi.v0.1.1.i686-linux-gnu.tar.gz", "79f5d2fb4156e59a41ae6122f2a9bf66cfc89f72272b69d3b4b76f7a72a15d9c"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Hanabi.v0.1.1.i686-linux-musl.tar.gz", "52fda35d49808d438c03b29117330bc73525218aa22e69bdab5fdc864ba95bce"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Hanabi.v0.1.1.powerpc64le-linux-gnu.tar.gz", "943c2134d7054791c7487a1e1ef895ec2c6d5ab5120491709d625aa5878af415"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Hanabi.v0.1.1.x86_64-linux-gnu.tar.gz", "f7bdd3c58f952b631e7a1a7159ec4b8a14eb480a80742d8eb2260bf89982d946"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Hanabi.v0.1.1.x86_64-linux-musl.tar.gz", "b714417bd07f974350f90deb833f60806b0392ad348198b91ed1458ff10b1fca"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)