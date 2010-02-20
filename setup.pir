#!/usr/bin/env parrot
# Copyright (C) 2010, Parrot Foundation.

=head1 NAME

setup.pir - Python distutils style

=head1 DESCRIPTION

No Configure step, no Makefile generated.

See F<runtime/parrot/library/distutils.pir>.

=head1 USAGE

    $ parrot setup.pir build
    $ parrot setup.pir test
    $ sudo parrot setup.pir install

=cut

.sub 'main' :main
    .param pmc args
    $S0 = shift args
    load_bytecode 'distutils.pbc'
    load_bytecode 'Configure/genfile.pbc'

    .const 'Sub' prebuild = 'prebuild'
    register_step_before('build', prebuild)

    .const 'Sub' clean = 'clean'
    register_step_after('clean', clean)

    $P0 = new 'Hash'
    $P0['name'] = 'digest-dynpmcs'
    $P0['abstract'] = 'Set of message-digest dynpmcs for the Parrot VM.'
    $P0['authority'] = 'http://github.com/fperrad'
    $P0['description'] = 'libssl-powered md2, md4, md5, ripemd160, sha, sha1, sha256 and sha512 dynpmcs for Parrot.'
    $P1 = split ',', 'digest,dynpmc,md2,md4,md5,ripemd160,sha,sha1,sha256,sha512'
    $P0['keywords'] = $P1
    $P0['license_type'] = 'Artistic License 2.0'
    $P0['license_uri'] = 'http://www.perlfoundation.org/artistic_license_2_0'
    $P0['copyright_holder'] = 'Parrot Foundation'
    $P0['checkout_uri'] = 'git://github.com/fperrad/digest-dynpmcs.git'
    $P0['browser_uri'] = 'http://github.com/fperrad/digest-dynpmcs'
    $P0['project_uri'] = 'http://github.com/fperrad/digest-dynpmcs'

    # build
    $P2 = new 'Hash'
    $P3 = split "\n", <<'GENERATED_FILES'
src/pmc/md2.pmc
src/pmc/md4.pmc
src/pmc/md5.pmc
src/pmc/ripemd160.pmc
src/pmc/sha.pmc
src/pmc/sha1.pmc
src/pmc/sha256.pmc
src/pmc/sha512.pmc
GENERATED_FILES
    $S0 = pop $P3
    $P2['digest_group'] = $P3
    $P0['dynpmc'] = $P2
    $S0 = get_ldflags()
    $P0['dynpmc_ldflags'] = $S0

    # test
    $S0 = get_parrot()
    $P0['prove_exec'] = $S0

    # dist
    $P0['doc_files'] = 'README'
    $P4 = split "\n", <<'GENERATED_FILES'
src/pmc/md2.pmc
src/pmc/md4.pmc
src/pmc/md5.pmc
src/pmc/ripemd160.pmc
src/pmc/sha.pmc
src/pmc/sha1.pmc
src/pmc/sha256.pmc
src/pmc/sha512.pmc
t/md2.t
t/md4.t
t/md5.t
t/ripemd160.t
t/sha.t
t/sha1.t
t/sha256.t
t/sha512.t
GENERATED_FILES
    $S0 = pop $P4
    $P0['manifest_excludes'] = $P4
    $P5 = split ' ', 'src/pmc/digest_pmc.in t/digest_t.in'
    $P0['manifest_includes'] = $P5

    .tailcall setup(args :flat, $P0 :flat :named)
.end

.sub 'prebuild' :anon
    .param pmc kv :slurpy :named
    .local pmc config
    config = get_config()
    .local string openssl_version
    openssl_version  = detect_openssl()
    openssl_version  = config['openssl_version']

    .local pmc md2, md4, md5, ripemd160, sha, sha1, sha256, sha512
    md2 = new 'Hash'
    md2['md_result'] = 'ab4f496bfb2a530b219ff33031fe06b0'
    md4 = new 'Hash'
    md4['md_result'] = 'd9130a8164549fe818874806e1c7014b'
    md5 = new 'Hash'
    md5['md_result'] = 'f96b697d7cb7938d525a2f31aaf161d0'
    ripemd160 = new 'Hash'
    ripemd160['md_result'] = '5d0689ef49d2fae572b881b123a85ffa21595f36'
    ripemd160['md_inc'] = 'ripemd'
    sha = new 'Hash'
    sha['md_result'] = 'c1b0f222d150ebb9aa36a40cafdc8bcbed830b14'
    sha1 = new 'Hash'
    sha1['md_result'] = 'c12252ceda8be8994d5fa0290a47231c1d16aae3'
    sha1['md_inc'] = 'sha'
    sha1['md_ctx'] = 'SHA_CTX'
    sha1['md_digest'] = 'SHA_DIGEST'
    sha256 = new 'Hash'
    sha256['md_result'] = 'f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650'
    sha256['md_inc'] = 'sha'
    sha256['version_needed'] = '0.9.8a'
    sha512 = new 'Hash'
    sha512['md_result'] = '107dbf389d9e9f71a3a95f6c055b9251bc5268c2be16d6c13492ea45b0199f3309e16455ab1e96118e8a905d5597b72038ddb372a89826046de66687bb420e7c'
    sha512['md_inc'] = 'sha'
    sha512['version_needed'] = '0.9.8a'
    $P0 = new 'Hash'
    $P0['MD2'] = md2
    $P0['MD4'] = md4
    $P0['MD5'] = md5
    $P0['RIPEMD160'] = ripemd160
    $P0['SHA'] = sha
    $P0['SHA1'] = sha1
    $P0['SHA256'] = sha256
    $P0['SHA512'] = sha512

    $P1 = iter $P0
  L1:
    unless $P1 goto L2
    .local string md, file
    md = shift $P1
    $P2 = $P0[md]
    file = downcase md

    config['TEMP_md_name'] = md
    config['TEMP_md_file'] = file
    $S0 = file
    $I0 = exists $P2['md_inc']
    unless $I0 goto L11
    $S0 = $P2['md_inc']
  L11:
    config['TEMP_md_inc'] = $S0
    $S0 = md . '_CTX'
    $I0 = exists $P2['md_ctx']
    unless $I0 goto L12
    $S0 = $P2['md_ctx']
  L12:
    config['TEMP_md_ctx'] = $S0
    $S0 = md . '_DIGEST'
    $I0 = exists $P2['md_digest']
    unless $I0 goto L13
    $S0 = $P2['md_digest']
  L13:
    config['TEMP_md_digest'] = $S0
    $S0 = '#ifndef OPENSSL_NO_' . md
    $I0 = exists $P2['version_needed']
    unless $I0 goto L14
    $S1 = $P2['version_needed']
    unless openssl_version < $S1 goto L14
    $S0 = '#if 0'
  L14:
    config['TEMP_md_guard'] = $S0
    $S0 = '0.9'
    $I0 = exists $P2['version_needed']
    unless $I0 goto L15
    $S0 = $P2['version_needed']
  L15:
    config['TEMP_md_skip'] = $S0
    $S0 = $P2['md_result']
    config['TEMP_md_result'] = $S0

    $S0 = 'src/pmc/' . file
    $S0 .= '.pmc'
    $I0 = newer($S0, 'src/pmc/digest_pmc.in')
    if $I0 goto L21
    genfile('src/pmc/digest_pmc.in', $S0, config, 1 :named('verbose'))
  L21:
    $S0 = 't/' . file
    $S0 .= '.t'
    $I0 = newer($S0, 't/digest_t.in')
    if $I0 goto L22
    genfile('t/digest_t.in', $S0, config, 1 :named('verbose'))
  L22:
    goto L1
  L2:
.end

.sub 'clean' :anon
    .param pmc kv :slurpy :named
    $P0 = glob('src/pmc/*.pmc t/*.t')
    unlink($P0, 1 :named('verbose'))
.end

.sub 'detect_openssl' :anon
    # currently, uses Parrot's config
    .local pmc config
    config = get_config()
    $I0 = config['has_crypto']
    if $I0 goto L1
    die "no crypto"
  L1:
    $S0 = config['openssl_version']
    .return ($S0)
.end

.sub 'get_ldflags' :anon
    .local pmc config
    config = get_config()
    $S0 = '-lcrypto'
    $S1 = config['osname']
    unless $S1 == 'win32' goto L1
    $S2 = config['cc']
    if $S2 == 'gcc' goto L1
    $S0 = 'libcrypto.lib'
  L1:
    .return ($S0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

