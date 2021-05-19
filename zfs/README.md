## Сжатие файловых систем ZFS

Сжатие - это процесс хранения данных с использованием меньшего дискового пространства. Доступны следующие алгоритмы сжатия:

gzip - стандартное сжатие UNIX.

gzip- N - выбирает определенный уровень gzip. gzip-1 обеспечивает самое быстрое сжатие gzip. gzip-9 обеспечивает наилучшее сжатие данных. По умолчанию используется gzip-6 .

lz4 - обеспечивает лучшее сжатие с меньшими затратами процессора

lzjb - оптимизирован для производительности, обеспечивая при этом достойное сжатие

zle - кодирование нулевой длины полезно для наборов данных с большими блоками нулей

Примечание.  В настоящее время сжатие lz4 или gzip в корневых пулах не поддерживается.
Вы можете выбрать конкретный алгоритм сжатия, установив свойство сжатия ZFS. Чтобы использовать алгоритм LZ4, используйте следующую команду:

zfs set compress = lz4 pool/fs

#### Определение алгоритма с наилучшим сжатием

Создаем zfs pool в режиме raidz2:
```
zpool create hybrid raidz2 sdb sdc sdd sde sdf sdg
```
Создаем файловые системы:
```
zfs create hybrid/data1
zfs create hybrid/data2
zfs create hybrid/data3
zfs create hybrid/data4
zfs create hybrid/data5
```
Устанавливаем алгоритмы сжатия на созданные файловые системы:

`zfs set compression=gzip hybrid/data1`

 `zfs set compression=gzip-9 hybrid/data2`
 
 `zfs set compression=lz4 hybrid/data3`
 
 `zfs set compression=zle hybrid/data4`
 
 `zfs set compression=lzjb hybrid/data5`
 
 Тестирование лучшего сжатия проводим на распакованном архиве c ядром linux-5.12.4.
 Результаты:
 
```
hybrid/data1  compression    gzip      local
hybrid/data1  compressratio  4.45x     -
hybrid/data2  compression    gzip-9    local
hybrid/data2  compressratio  4.48x     -
hybrid/data3  compression    lz4       local
hybrid/data3  compressratio  2.87x     -
hybrid/data4  compression    zle       local
hybrid/data4  compressratio  1.08x     -
hybrid/data5  compression    lzjb      local
hybrid/data5  compressratio  2.49x     -
```
Очевидно, что gzip-9 справился с этой задачей лучше всех.

 


