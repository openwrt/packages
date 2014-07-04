define Package/perlbase-template
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
URL:=http://www.cpan.org/
DEPENDS:=perl
endef

define Package/perlbase-abbrev
$(call Package/perlbase-template)
TITLE:=abbrev perl module
endef

define Package/perlbase-abbrev/install
$(call perlmod/Install,$(1),abbrev.pl,)
endef

$(eval $(call BuildPackage,perlbase-abbrev))


define Package/perlbase-anydbm-file
$(call Package/perlbase-template)
TITLE:=AnyDBM_File perl module
endef

define Package/perlbase-anydbm-file/install
$(call perlmod/Install,$(1),AnyDBM_File.pm,)
endef

$(eval $(call BuildPackage,perlbase-anydbm-file))


define Package/perlbase-archive
$(call Package/perlbase-template)
TITLE:=Archive perl module
endef

define Package/perlbase-archive/install
$(call perlmod/Install,$(1),Archive,)
endef

$(eval $(call BuildPackage,perlbase-archive))


define Package/perlbase-assert
$(call Package/perlbase-template)
TITLE:=assert perl module
endef

define Package/perlbase-assert/install
$(call perlmod/Install,$(1),assert.pl,)
endef

$(eval $(call BuildPackage,perlbase-assert))


define Package/perlbase-attribute
$(call Package/perlbase-template)
TITLE:=Attribute perl module
endef

define Package/perlbase-attribute/install
$(call perlmod/Install,$(1),Attribute,)
endef

$(eval $(call BuildPackage,perlbase-attribute))


define Package/perlbase-attributes
$(call Package/perlbase-template)
TITLE:=attributes perl module
endef

define Package/perlbase-attributes/install
$(call perlmod/Install,$(1),attributes.pm,)
endef

$(eval $(call BuildPackage,perlbase-attributes))


define Package/perlbase-attrs
$(call Package/perlbase-template)
TITLE:=attrs perl module
endef

define Package/perlbase-attrs/install
$(call perlmod/Install,$(1),attrs.pm auto/attrs,)
endef

$(eval $(call BuildPackage,perlbase-attrs))


define Package/perlbase-autoloader
$(call Package/perlbase-template)
TITLE:=AutoLoader perl module
endef

define Package/perlbase-autoloader/install
$(call perlmod/Install,$(1),AutoLoader.pm,)
endef

$(eval $(call BuildPackage,perlbase-autoloader))


define Package/perlbase-autosplit
$(call Package/perlbase-template)
TITLE:=AutoSplit perl module
endef

define Package/perlbase-autosplit/install
$(call perlmod/Install,$(1),AutoSplit.pm,)
endef

$(eval $(call BuildPackage,perlbase-autosplit))


define Package/perlbase-autouse
$(call Package/perlbase-template)
TITLE:=autouse perl module
endef

define Package/perlbase-autouse/install
$(call perlmod/Install,$(1),autouse.pm,)
endef

$(eval $(call BuildPackage,perlbase-autouse))


define Package/perlbase-b
$(call Package/perlbase-template)
TITLE:=B perl module
endef

define Package/perlbase-b/install
$(call perlmod/Install,$(1),B B.pm auto/B,)
endef

$(eval $(call BuildPackage,perlbase-b))


define Package/perlbase-base
$(call Package/perlbase-template)
TITLE:=base perl module
endef

define Package/perlbase-base/install
$(call perlmod/Install,$(1),base.pm,)
endef

$(eval $(call BuildPackage,perlbase-base))


define Package/perlbase-benchmark
$(call Package/perlbase-template)
TITLE:=Benchmark perl module
endef

define Package/perlbase-benchmark/install
$(call perlmod/Install,$(1),Benchmark.pm,)
endef

$(eval $(call BuildPackage,perlbase-benchmark))


define Package/perlbase-bigfloat
$(call Package/perlbase-template)
TITLE:=bigfloat perl module
endef

define Package/perlbase-bigfloat/install
$(call perlmod/Install,$(1),bigfloat.pl,)
endef

$(eval $(call BuildPackage,perlbase-bigfloat))


define Package/perlbase-bigint
$(call Package/perlbase-template)
TITLE:=bigint perl module
endef

define Package/perlbase-bigint/install
$(call perlmod/Install,$(1),bigint.pl bigint.pm,)
endef

$(eval $(call BuildPackage,perlbase-bigint))


define Package/perlbase-bignum
$(call Package/perlbase-template)
TITLE:=bignum perl module
endef

define Package/perlbase-bignum/install
$(call perlmod/Install,$(1),bignum.pm,)
endef

$(eval $(call BuildPackage,perlbase-bignum))


define Package/perlbase-bigrat
$(call Package/perlbase-template)
TITLE:=bigrat perl module
endef

define Package/perlbase-bigrat/install
$(call perlmod/Install,$(1),bigrat.pl bigrat.pm,)
endef

$(eval $(call BuildPackage,perlbase-bigrat))


define Package/perlbase-blib
$(call Package/perlbase-template)
TITLE:=blib perl module
endef

define Package/perlbase-blib/install
$(call perlmod/Install,$(1),blib.pm,)
endef

$(eval $(call BuildPackage,perlbase-blib))


define Package/perlbase-bytes
$(call Package/perlbase-template)
TITLE:=bytes perl module
endef

define Package/perlbase-bytes/install
$(call perlmod/Install,$(1),bytes.pm bytes_heavy.pl,)
endef

$(eval $(call BuildPackage,perlbase-bytes))


define Package/perlbase-cacheout
$(call Package/perlbase-template)
TITLE:=cacheout perl module
endef

define Package/perlbase-cacheout/install
$(call perlmod/Install,$(1),cacheout.pl,)
endef

$(eval $(call BuildPackage,perlbase-cacheout))


define Package/perlbase-cgi
$(call Package/perlbase-template)
TITLE:=CGI perl module
endef

define Package/perlbase-cgi/install
$(call perlmod/Install,$(1),CGI CGI.pm,)
endef

$(eval $(call BuildPackage,perlbase-cgi))


define Package/perlbase-charnames
$(call Package/perlbase-template)
TITLE:=charnames perl module
endef

define Package/perlbase-charnames/install
$(call perlmod/Install,$(1),charnames.pm,)
endef

$(eval $(call BuildPackage,perlbase-charnames))


define Package/perlbase-class
$(call Package/perlbase-template)
TITLE:=Class perl module
endef

define Package/perlbase-class/install
$(call perlmod/Install,$(1),Class,)
endef

$(eval $(call BuildPackage,perlbase-class))


define Package/perlbase-complete
$(call Package/perlbase-template)
TITLE:=complete perl module
endef

define Package/perlbase-complete/install
$(call perlmod/Install,$(1),complete.pl,)
endef

$(eval $(call BuildPackage,perlbase-complete))


define Package/perlbase-compress
$(call Package/perlbase-template)
TITLE:=Compress perl module
endef

define Package/perlbase-compress/install
$(call perlmod/Install,$(1),Compress auto/Compress,)
endef

$(eval $(call BuildPackage,perlbase-compress))


define Package/perlbase-config
$(call Package/perlbase-template)
TITLE:=Config perl module
endef

define Package/perlbase-config/install
$(call perlmod/Install,$(1),Config Config.pm Config_heavy.pl,)
endef

$(eval $(call BuildPackage,perlbase-config))


define Package/perlbase-cpan
$(call Package/perlbase-template)
TITLE:=CPAN perl module
endef

define Package/perlbase-cpan/install
$(call perlmod/Install,$(1),CPAN CPAN.pm,)
endef

$(eval $(call BuildPackage,perlbase-cpan))


define Package/perlbase-cpanplus
$(call Package/perlbase-template)
TITLE:=CPANPLUS perl module
endef

define Package/perlbase-cpanplus/install
$(call perlmod/Install,$(1),CPANPLUS CPANPLUS.pm,CPANPLUS/FAQ.pod CPANPLUS/Hacking.pod CPANPLUS/Shell/Default/Plugins/HOWTO.pod)
endef

$(eval $(call BuildPackage,perlbase-cpanplus))


define Package/perlbase-ctime
$(call Package/perlbase-template)
TITLE:=ctime perl module
endef

define Package/perlbase-ctime/install
$(call perlmod/Install,$(1),ctime.pl,)
endef

$(eval $(call BuildPackage,perlbase-ctime))


define Package/perlbase-cwd
$(call Package/perlbase-template)
TITLE:=Cwd perl module
endef

define Package/perlbase-cwd/install
$(call perlmod/Install,$(1),Cwd.pm auto/Cwd,)
endef

$(eval $(call BuildPackage,perlbase-cwd))


define Package/perlbase-data
$(call Package/perlbase-template)
TITLE:=Data perl module
endef

define Package/perlbase-data/install
$(call perlmod/Install,$(1),Data auto/Data,)
endef

$(eval $(call BuildPackage,perlbase-data))


define Package/perlbase-db
$(call Package/perlbase-template)
TITLE:=DB perl module
DEPENDS+= +libdb47
endef

define Package/perlbase-db/install
$(call perlmod/Install,$(1),DB.pm,)
endef

$(eval $(call BuildPackage,perlbase-db))


define Package/perlbase-db-file
$(call Package/perlbase-template)
TITLE:=DB_File perl module
DEPENDS+= +libdb47
endef

define Package/perlbase-db-file/install
$(call perlmod/Install,$(1),DB_File.pm auto/DB_File,)
endef

$(eval $(call BuildPackage,perlbase-db-file))


define Package/perlbase-dbm-filter
$(call Package/perlbase-template)
TITLE:=DBM_Filter perl module
endef

define Package/perlbase-dbm-filter/install
$(call perlmod/Install,$(1),DBM_Filter DBM_Filter.pm,)
endef

$(eval $(call BuildPackage,perlbase-dbm-filter))


define Package/perlbase-devel
$(call Package/perlbase-template)
TITLE:=Devel perl module
endef

define Package/perlbase-devel/install
$(call perlmod/Install,$(1),Devel auto/Devel,)
endef

$(eval $(call BuildPackage,perlbase-devel))


define Package/perlbase-diagnostics
$(call Package/perlbase-template)
TITLE:=diagnostics perl module
endef

define Package/perlbase-diagnostics/install
$(call perlmod/Install,$(1),diagnostics.pm,)
endef

$(eval $(call BuildPackage,perlbase-diagnostics))


define Package/perlbase-digest
$(call Package/perlbase-template)
TITLE:=Digest perl module
endef

define Package/perlbase-digest/install
$(call perlmod/Install,$(1),Digest Digest.pm auto/Digest,)
endef

$(eval $(call BuildPackage,perlbase-digest))


define Package/perlbase-dirhandle
$(call Package/perlbase-template)
TITLE:=DirHandle perl module
endef

define Package/perlbase-dirhandle/install
$(call perlmod/Install,$(1),DirHandle.pm,)
endef

$(eval $(call BuildPackage,perlbase-dirhandle))


define Package/perlbase-dotsh
$(call Package/perlbase-template)
TITLE:=dotsh perl module
endef

define Package/perlbase-dotsh/install
$(call perlmod/Install,$(1),dotsh.pl,)
endef

$(eval $(call BuildPackage,perlbase-dotsh))


define Package/perlbase-dumpvalue
$(call Package/perlbase-template)
TITLE:=Dumpvalue perl module
endef

define Package/perlbase-dumpvalue/install
$(call perlmod/Install,$(1),Dumpvalue.pm,)
endef

$(eval $(call BuildPackage,perlbase-dumpvalue))


define Package/perlbase-dumpvar
$(call Package/perlbase-template)
TITLE:=dumpvar perl module
endef

define Package/perlbase-dumpvar/install
$(call perlmod/Install,$(1),dumpvar.pl,)
endef

$(eval $(call BuildPackage,perlbase-dumpvar))


define Package/perlbase-dynaloader
$(call Package/perlbase-template)
TITLE:=DynaLoader perl module
endef

define Package/perlbase-dynaloader/install
$(call perlmod/Install,$(1),DynaLoader.pm auto/DynaLoader,)
endef

$(eval $(call BuildPackage,perlbase-dynaloader))


define Package/perlbase-encode
$(call Package/perlbase-template)
TITLE:=Encode perl module
endef

define Package/perlbase-encode/install
$(call perlmod/Install,$(1),Encode Encode.pm auto/Encode,Encode/PerlIO.pod Encode/Supported.pod)
endef

$(eval $(call BuildPackage,perlbase-encode))


define Package/perlbase-encoding
$(call Package/perlbase-template)
TITLE:=encoding perl module
endef

define Package/perlbase-encoding/install
$(call perlmod/Install,$(1),encoding encoding.pm,)
endef

$(eval $(call BuildPackage,perlbase-encoding))


define Package/perlbase-english
$(call Package/perlbase-template)
TITLE:=English perl module
endef

define Package/perlbase-english/install
$(call perlmod/Install,$(1),English.pm,)
endef

$(eval $(call BuildPackage,perlbase-english))


define Package/perlbase-env
$(call Package/perlbase-template)
TITLE:=Env perl module
endef

define Package/perlbase-env/install
$(call perlmod/Install,$(1),Env.pm,)
endef

$(eval $(call BuildPackage,perlbase-env))


define Package/perlbase-errno
$(call Package/perlbase-template)
TITLE:=Errno perl module
endef

define Package/perlbase-errno/install
$(call perlmod/Install,$(1),Errno.pm,)
endef

$(eval $(call BuildPackage,perlbase-errno))


define Package/perlbase-essential
$(call Package/perlbase-template)
TITLE:=essential perl module
endef

define Package/perlbase-essential/install
$(call perlmod/Install,$(1),Carp Carp.pm Exporter Exporter.pm constant.pm lib.pm locale.pm overload.pm strict.pm subs.pm vars.pm warnings warnings.pm,)
endef

$(eval $(call BuildPackage,perlbase-essential))


define Package/perlbase-exceptions
$(call Package/perlbase-template)
TITLE:=exceptions perl module
endef

define Package/perlbase-exceptions/install
$(call perlmod/Install,$(1),exceptions.pl,)
endef

$(eval $(call BuildPackage,perlbase-exceptions))


define Package/perlbase-extutils
$(call Package/perlbase-template)
TITLE:=ExtUtils perl module
endef

define Package/perlbase-extutils/install
$(call perlmod/Install,$(1),ExtUtils,ExtUtils/MakeMaker/FAQ.pod ExtUtils/MakeMaker/Tutorial.pod)
endef

$(eval $(call BuildPackage,perlbase-extutils))


define Package/perlbase-fastcwd
$(call Package/perlbase-template)
TITLE:=fastcwd perl module
endef

define Package/perlbase-fastcwd/install
$(call perlmod/Install,$(1),fastcwd.pl,)
endef

$(eval $(call BuildPackage,perlbase-fastcwd))


define Package/perlbase-fatal
$(call Package/perlbase-template)
TITLE:=Fatal perl module
endef

define Package/perlbase-fatal/install
$(call perlmod/Install,$(1),Fatal.pm,)
endef

$(eval $(call BuildPackage,perlbase-fatal))


define Package/perlbase-fcntl
$(call Package/perlbase-template)
TITLE:=Fcntl perl module
endef

define Package/perlbase-fcntl/install
$(call perlmod/Install,$(1),Fcntl.pm auto/Fcntl,)
endef

$(eval $(call BuildPackage,perlbase-fcntl))


define Package/perlbase-feature
$(call Package/perlbase-template)
TITLE:=feature perl module
endef

define Package/perlbase-feature/install
$(call perlmod/Install,$(1),feature.pm,)
endef

$(eval $(call BuildPackage,perlbase-feature))


define Package/perlbase-fields
$(call Package/perlbase-template)
TITLE:=fields perl module
endef

define Package/perlbase-fields/install
$(call perlmod/Install,$(1),fields.pm,)
endef

$(eval $(call BuildPackage,perlbase-fields))


define Package/perlbase-file
$(call Package/perlbase-template)
TITLE:=File perl module
endef

define Package/perlbase-file/install
$(call perlmod/Install,$(1),File auto/File,)
endef

$(eval $(call BuildPackage,perlbase-file))


define Package/perlbase-filecache
$(call Package/perlbase-template)
TITLE:=FileCache perl module
endef

define Package/perlbase-filecache/install
$(call perlmod/Install,$(1),FileCache.pm,)
endef

$(eval $(call BuildPackage,perlbase-filecache))


define Package/perlbase-filehandle
$(call Package/perlbase-template)
TITLE:=FileHandle perl module
endef

define Package/perlbase-filehandle/install
$(call perlmod/Install,$(1),FileHandle.pm,)
endef

$(eval $(call BuildPackage,perlbase-filehandle))


define Package/perlbase-filetest
$(call Package/perlbase-template)
TITLE:=filetest perl module
endef

define Package/perlbase-filetest/install
$(call perlmod/Install,$(1),filetest.pm,)
endef

$(eval $(call BuildPackage,perlbase-filetest))


define Package/perlbase-filter
$(call Package/perlbase-template)
TITLE:=Filter perl module
endef

define Package/perlbase-filter/install
$(call perlmod/Install,$(1),Filter auto/Filter,)
endef

$(eval $(call BuildPackage,perlbase-filter))


define Package/perlbase-find
$(call Package/perlbase-template)
TITLE:=find perl module
endef

define Package/perlbase-find/install
$(call perlmod/Install,$(1),find.pl,)
endef

$(eval $(call BuildPackage,perlbase-find))


define Package/perlbase-findbin
$(call Package/perlbase-template)
TITLE:=FindBin perl module
endef

define Package/perlbase-findbin/install
$(call perlmod/Install,$(1),FindBin.pm,)
endef

$(eval $(call BuildPackage,perlbase-findbin))


define Package/perlbase-finddepth
$(call Package/perlbase-template)
TITLE:=finddepth perl module
endef

define Package/perlbase-finddepth/install
$(call perlmod/Install,$(1),finddepth.pl,)
endef

$(eval $(call BuildPackage,perlbase-finddepth))


define Package/perlbase-flush
$(call Package/perlbase-template)
TITLE:=flush perl module
endef

define Package/perlbase-flush/install
$(call perlmod/Install,$(1),flush.pl,)
endef

$(eval $(call BuildPackage,perlbase-flush))


define Package/perlbase-gdbm-file
$(call Package/perlbase-template)
TITLE:=GDBM_File perl module
DEPENDS+= +libgdbm
endef

define Package/perlbase-gdbm-file/install
$(call perlmod/Install,$(1),GDBM_File.pm auto/GDBM_File,)
endef

$(eval $(call BuildPackage,perlbase-gdbm-file))


define Package/perlbase-getcwd
$(call Package/perlbase-template)
TITLE:=getcwd perl module
endef

define Package/perlbase-getcwd/install
$(call perlmod/Install,$(1),getcwd.pl,)
endef

$(eval $(call BuildPackage,perlbase-getcwd))


define Package/perlbase-getopt
$(call Package/perlbase-template)
TITLE:=Getopt perl module
endef

define Package/perlbase-getopt/install
$(call perlmod/Install,$(1),Getopt newgetopt.pl,)
endef

$(eval $(call BuildPackage,perlbase-getopt))


define Package/perlbase-getoptpl
$(call Package/perlbase-template)
TITLE:=getoptpl perl module
endef

define Package/perlbase-getoptpl/install
$(call perlmod/Install,$(1),getopt.pl getopts.pl,)
endef

$(eval $(call BuildPackage,perlbase-getoptpl))


define Package/perlbase-hash
$(call Package/perlbase-template)
TITLE:=Hash perl module
endef

define Package/perlbase-hash/install
$(call perlmod/Install,$(1),Hash auto/Hash,)
endef

$(eval $(call BuildPackage,perlbase-hash))


define Package/perlbase-hostname
$(call Package/perlbase-template)
TITLE:=hostname perl module
endef

define Package/perlbase-hostname/install
$(call perlmod/Install,$(1),hostname.pl,)
endef

$(eval $(call BuildPackage,perlbase-hostname))


define Package/perlbase-i18n
$(call Package/perlbase-template)
TITLE:=I18N perl module
endef

define Package/perlbase-i18n/install
$(call perlmod/Install,$(1),I18N auto/I18N,)
endef

$(eval $(call BuildPackage,perlbase-i18n))


define Package/perlbase-if
$(call Package/perlbase-template)
TITLE:=if perl module
endef

define Package/perlbase-if/install
$(call perlmod/Install,$(1),if.pm,)
endef

$(eval $(call BuildPackage,perlbase-if))


define Package/perlbase-importenv
$(call Package/perlbase-template)
TITLE:=importenv perl module
endef

define Package/perlbase-importenv/install
$(call perlmod/Install,$(1),importenv.pl,)
endef

$(eval $(call BuildPackage,perlbase-importenv))


define Package/perlbase-integer
$(call Package/perlbase-template)
TITLE:=integer perl module
endef

define Package/perlbase-integer/install
$(call perlmod/Install,$(1),integer.pm,)
endef

$(eval $(call BuildPackage,perlbase-integer))


define Package/perlbase-io
$(call Package/perlbase-template)
TITLE:=IO perl module
endef

define Package/perlbase-io/install
$(call perlmod/Install,$(1),IO IO.pm auto/IO,)
endef

$(eval $(call BuildPackage,perlbase-io))


define Package/perlbase-ipc
$(call Package/perlbase-template)
TITLE:=IPC perl module
endef

define Package/perlbase-ipc/install
$(call perlmod/Install,$(1),IPC auto/IPC,)
endef

$(eval $(call BuildPackage,perlbase-ipc))


define Package/perlbase-less
$(call Package/perlbase-template)
TITLE:=less perl module
endef

define Package/perlbase-less/install
$(call perlmod/Install,$(1),less.pm,)
endef

$(eval $(call BuildPackage,perlbase-less))


define Package/perlbase-list
$(call Package/perlbase-template)
TITLE:=List perl module
endef

define Package/perlbase-list/install
$(call perlmod/Install,$(1),List auto/List,)
endef

$(eval $(call BuildPackage,perlbase-list))


define Package/perlbase-locale
$(call Package/perlbase-template)
TITLE:=Locale perl module
endef

define Package/perlbase-locale/install
$(call perlmod/Install,$(1),Locale,Locale/Constants.pod Locale/Country.pod Locale/Currency.pod Locale/Language.pod Locale/Maketext.pod Locale/Maketext/TPJ13.pod Locale/Script.pod)
endef

$(eval $(call BuildPackage,perlbase-locale))


define Package/perlbase-log
$(call Package/perlbase-template)
TITLE:=Log perl module
endef

define Package/perlbase-log/install
$(call perlmod/Install,$(1),Log,)
endef

$(eval $(call BuildPackage,perlbase-log))


define Package/perlbase-look
$(call Package/perlbase-template)
TITLE:=look perl module
endef

define Package/perlbase-look/install
$(call perlmod/Install,$(1),look.pl,)
endef

$(eval $(call BuildPackage,perlbase-look))


define Package/perlbase-math
$(call Package/perlbase-template)
TITLE:=Math perl module
endef

define Package/perlbase-math/install
$(call perlmod/Install,$(1),Math auto/Math,)
endef

$(eval $(call BuildPackage,perlbase-math))


define Package/perlbase-memoize
$(call Package/perlbase-template)
TITLE:=Memoize perl module
endef

define Package/perlbase-memoize/install
$(call perlmod/Install,$(1),Memoize Memoize.pm,)
endef

$(eval $(call BuildPackage,perlbase-memoize))


define Package/perlbase-mime
$(call Package/perlbase-template)
TITLE:=MIME perl module
endef

define Package/perlbase-mime/install
$(call perlmod/Install,$(1),MIME auto/MIME,)
endef

$(eval $(call BuildPackage,perlbase-mime))


define Package/perlbase-module
$(call Package/perlbase-template)
TITLE:=Module perl module
endef

define Package/perlbase-module/install
$(call perlmod/Install,$(1),Module,Module/Build/API.pod Module/Build/Authoring.pod)
endef

$(eval $(call BuildPackage,perlbase-module))


define Package/perlbase-mro
$(call Package/perlbase-template)
TITLE:=mro perl module
endef

define Package/perlbase-mro/install
$(call perlmod/Install,$(1),mro.pm,)
endef

$(eval $(call BuildPackage,perlbase-mro))


define Package/perlbase-net
$(call Package/perlbase-template)
TITLE:=Net perl module
endef

define Package/perlbase-net/install
$(call perlmod/Install,$(1),Net,Net/libnetFAQ.pod)
endef

$(eval $(call BuildPackage,perlbase-net))


define Package/perlbase-next
$(call Package/perlbase-template)
TITLE:=NEXT perl module
endef

define Package/perlbase-next/install
$(call perlmod/Install,$(1),NEXT.pm,)
endef

$(eval $(call BuildPackage,perlbase-next))


define Package/perlbase-o
$(call Package/perlbase-template)
TITLE:=O perl module
endef

define Package/perlbase-o/install
$(call perlmod/Install,$(1),O.pm,)
endef

$(eval $(call BuildPackage,perlbase-o))


define Package/perlbase-object
$(call Package/perlbase-template)
TITLE:=Object perl module
endef

define Package/perlbase-object/install
$(call perlmod/Install,$(1),Object,)
endef

$(eval $(call BuildPackage,perlbase-object))


define Package/perlbase-opcode
$(call Package/perlbase-template)
TITLE:=Opcode perl module
endef

define Package/perlbase-opcode/install
$(call perlmod/Install,$(1),Opcode.pm auto/Opcode,)
endef

$(eval $(call BuildPackage,perlbase-opcode))


define Package/perlbase-open
$(call Package/perlbase-template)
TITLE:=open perl module
endef

define Package/perlbase-open/install
$(call perlmod/Install,$(1),open.pm open2.pl open3.pl,)
endef

$(eval $(call BuildPackage,perlbase-open))


define Package/perlbase-ops
$(call Package/perlbase-template)
TITLE:=ops perl module
endef

define Package/perlbase-ops/install
$(call perlmod/Install,$(1),ops.pm,)
endef

$(eval $(call BuildPackage,perlbase-ops))


define Package/perlbase-package
$(call Package/perlbase-template)
TITLE:=Package perl module
endef

define Package/perlbase-package/install
$(call perlmod/Install,$(1),Package,)
endef

$(eval $(call BuildPackage,perlbase-package))


define Package/perlbase-params
$(call Package/perlbase-template)
TITLE:=Params perl module
endef

define Package/perlbase-params/install
$(call perlmod/Install,$(1),Params,)
endef

$(eval $(call BuildPackage,perlbase-params))


define Package/perlbase-perl5db
$(call Package/perlbase-template)
TITLE:=perl5db perl module
endef

define Package/perlbase-perl5db/install
$(call perlmod/Install,$(1),perl5db.pl,)
endef

$(eval $(call BuildPackage,perlbase-perl5db))


define Package/perlbase-perlio
$(call Package/perlbase-template)
TITLE:=PerlIO perl module
endef

define Package/perlbase-perlio/install
$(call perlmod/Install,$(1),PerlIO PerlIO.pm auto/PerlIO,)
endef

$(eval $(call BuildPackage,perlbase-perlio))

define Package/perlbase-pod
$(call Package/perlbase-template)
TITLE:=Pod perl module
endef

define Package/perlbase-pod/install
$(call perlmod/Install,$(1),Pod,)
endef

$(eval $(call BuildPackage,perlbase-pod))


define Package/perlbase-posix
$(call Package/perlbase-template)
TITLE:=POSIX perl module
endef

define Package/perlbase-posix/install
$(call perlmod/Install,$(1),POSIX.pm auto/POSIX,)
endef

$(eval $(call BuildPackage,perlbase-posix))


define Package/perlbase-pwd
$(call Package/perlbase-template)
TITLE:=pwd perl module
endef

define Package/perlbase-pwd/install
$(call perlmod/Install,$(1),pwd.pl,)
endef

$(eval $(call BuildPackage,perlbase-pwd))


define Package/perlbase-re
$(call Package/perlbase-template)
TITLE:=re perl module
endef

define Package/perlbase-re/install
$(call perlmod/Install,$(1),auto/re re.pm,)
endef

$(eval $(call BuildPackage,perlbase-re))


define Package/perlbase-safe
$(call Package/perlbase-template)
TITLE:=Safe perl module
endef

define Package/perlbase-safe/install
$(call perlmod/Install,$(1),Safe.pm,)
endef

$(eval $(call BuildPackage,perlbase-safe))


define Package/perlbase-scalar
$(call Package/perlbase-template)
TITLE:=Scalar perl module
endef

define Package/perlbase-scalar/install
$(call perlmod/Install,$(1),Scalar,)
endef

$(eval $(call BuildPackage,perlbase-scalar))


define Package/perlbase-sdbm-file
$(call Package/perlbase-template)
TITLE:=SDBM_File perl module
endef

define Package/perlbase-sdbm-file/install
$(call perlmod/Install,$(1),SDBM_File.pm auto/SDBM_File,)
endef

$(eval $(call BuildPackage,perlbase-sdbm-file))


define Package/perlbase-search
$(call Package/perlbase-template)
TITLE:=Search perl module
endef

define Package/perlbase-search/install
$(call perlmod/Install,$(1),Search,)
endef

$(eval $(call BuildPackage,perlbase-search))


define Package/perlbase-selectsaver
$(call Package/perlbase-template)
TITLE:=SelectSaver perl module
endef

define Package/perlbase-selectsaver/install
$(call perlmod/Install,$(1),SelectSaver.pm,)
endef

$(eval $(call BuildPackage,perlbase-selectsaver))


define Package/perlbase-selfloader
$(call Package/perlbase-template)
TITLE:=SelfLoader perl module
endef

define Package/perlbase-selfloader/install
$(call perlmod/Install,$(1),SelfLoader.pm,)
endef

$(eval $(call BuildPackage,perlbase-selfloader))


define Package/perlbase-shell
$(call Package/perlbase-template)
TITLE:=Shell perl module
endef

define Package/perlbase-shell/install
$(call perlmod/Install,$(1),Shell.pm,)
endef

$(eval $(call BuildPackage,perlbase-shell))


define Package/perlbase-shellwords
$(call Package/perlbase-template)
TITLE:=shellwords perl module
endef

define Package/perlbase-shellwords/install
$(call perlmod/Install,$(1),shellwords.pl,)
endef

$(eval $(call BuildPackage,perlbase-shellwords))


define Package/perlbase-sigtrap
$(call Package/perlbase-template)
TITLE:=sigtrap perl module
endef

define Package/perlbase-sigtrap/install
$(call perlmod/Install,$(1),sigtrap.pm,)
endef

$(eval $(call BuildPackage,perlbase-sigtrap))


define Package/perlbase-socket
$(call Package/perlbase-template)
TITLE:=Socket perl module
endef

define Package/perlbase-socket/install
$(call perlmod/Install,$(1),Socket.pm auto/Socket,)
endef

$(eval $(call BuildPackage,perlbase-socket))


define Package/perlbase-sort
$(call Package/perlbase-template)
TITLE:=sort perl module
endef

define Package/perlbase-sort/install
$(call perlmod/Install,$(1),sort.pm,)
endef

$(eval $(call BuildPackage,perlbase-sort))


define Package/perlbase-stat
$(call Package/perlbase-template)
TITLE:=stat perl module
endef

define Package/perlbase-stat/install
$(call perlmod/Install,$(1),stat.pl,)
endef

$(eval $(call BuildPackage,perlbase-stat))


define Package/perlbase-storable
$(call Package/perlbase-template)
TITLE:=Storable perl module
endef

define Package/perlbase-storable/install
$(call perlmod/Install,$(1),Storable.pm auto/Storable,)
endef

$(eval $(call BuildPackage,perlbase-storable))


define Package/perlbase-switch
$(call Package/perlbase-template)
TITLE:=Switch perl module
endef

define Package/perlbase-switch/install
$(call perlmod/Install,$(1),Switch.pm,)
endef

$(eval $(call BuildPackage,perlbase-switch))


define Package/perlbase-symbol
$(call Package/perlbase-template)
TITLE:=Symbol perl module
endef

define Package/perlbase-symbol/install
$(call perlmod/Install,$(1),Symbol.pm,)
endef

$(eval $(call BuildPackage,perlbase-symbol))


define Package/perlbase-sys
$(call Package/perlbase-template)
TITLE:=Sys perl module
endef

define Package/perlbase-sys/install
$(call perlmod/Install,$(1),Sys auto/Sys,)
endef

$(eval $(call BuildPackage,perlbase-sys))


define Package/perlbase-syslog
$(call Package/perlbase-template)
TITLE:=syslog perl module
endef

define Package/perlbase-syslog/install
$(call perlmod/Install,$(1),syslog.pl,)
endef

$(eval $(call BuildPackage,perlbase-syslog))


define Package/perlbase-tainted
$(call Package/perlbase-template)
TITLE:=tainted perl module
endef

define Package/perlbase-tainted/install
$(call perlmod/Install,$(1),tainted.pl,)
endef

$(eval $(call BuildPackage,perlbase-tainted))


define Package/perlbase-term
$(call Package/perlbase-template)
TITLE:=Term perl module
endef

define Package/perlbase-term/install
$(call perlmod/Install,$(1),Term,)
endef

$(eval $(call BuildPackage,perlbase-term))


define Package/perlbase-termcap
$(call Package/perlbase-template)
TITLE:=termcap perl module
endef

define Package/perlbase-termcap/install
$(call perlmod/Install,$(1),termcap.pl,)
endef

$(eval $(call BuildPackage,perlbase-termcap))


define Package/perlbase-test
$(call Package/perlbase-template)
TITLE:=Test perl module
endef

define Package/perlbase-test/install
$(call perlmod/Install,$(1),Test Test.pm,Test/Harness/TAP.pod Test/Tutorial.pod)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/prove $(1)/usr/bin
	$(call perlmod/Install,$(1),Test Test.pm,Test/Harness/TAP.pod Test/Tutorial.pod)
endef

$(eval $(call BuildPackage,perlbase-test))


define Package/perlbase-text
$(call Package/perlbase-template)
TITLE:=Text perl module
endef

define Package/perlbase-text/install
$(call perlmod/Install,$(1),Text auto/Text,)
endef

$(eval $(call BuildPackage,perlbase-text))


define Package/perlbase-thread
$(call Package/perlbase-template)
TITLE:=Thread perl module
endef

define Package/perlbase-thread/install
$(call perlmod/Install,$(1),Thread Thread.pm,)
endef

$(eval $(call BuildPackage,perlbase-thread))


define Package/perlbase-threads
$(call Package/perlbase-template)
TITLE:=threads perl module
endef

define Package/perlbase-threads/install
$(call perlmod/Install,$(1),auto/threads threads threads.pm,)
endef

$(eval $(call BuildPackage,perlbase-threads))


define Package/perlbase-tie
$(call Package/perlbase-template)
TITLE:=Tie perl module
endef

define Package/perlbase-tie/install
$(call perlmod/Install,$(1),Tie,)
endef

$(eval $(call BuildPackage,perlbase-tie))


define Package/perlbase-time
$(call Package/perlbase-template)
TITLE:=Time perl module
endef

define Package/perlbase-time/install
$(call perlmod/Install,$(1),Time auto/Time,)
endef

$(eval $(call BuildPackage,perlbase-time))


define Package/perlbase-timelocal
$(call Package/perlbase-template)
TITLE:=timelocal perl module
endef

define Package/perlbase-timelocal/install
$(call perlmod/Install,$(1),timelocal.pl,)
endef

$(eval $(call BuildPackage,perlbase-timelocal))


define Package/perlbase-unicode
$(call Package/perlbase-template)
TITLE:=Unicode perl module
endef

define Package/perlbase-unicode/install
$(call perlmod/Install,$(1),Unicode auto/Unicode,)
endef

$(eval $(call BuildPackage,perlbase-unicode))


define Package/perlbase-unicore
$(call Package/perlbase-template)
TITLE:=unicore perl module
endef

define Package/perlbase-unicore/install
$(call perlmod/Install,$(1),unicore,)
endef

$(eval $(call BuildPackage,perlbase-unicore))


define Package/perlbase-universal
$(call Package/perlbase-template)
TITLE:=UNIVERSAL perl module
endef

define Package/perlbase-universal/install
$(call perlmod/Install,$(1),UNIVERSAL.pm,)
endef

$(eval $(call BuildPackage,perlbase-universal))


define Package/perlbase-user
$(call Package/perlbase-template)
TITLE:=User perl module
endef

define Package/perlbase-user/install
$(call perlmod/Install,$(1),User,)
endef

$(eval $(call BuildPackage,perlbase-user))


define Package/perlbase-utf8
$(call Package/perlbase-template)
TITLE:=utf8 perl module
endef

define Package/perlbase-utf8/install
$(call perlmod/Install,$(1),utf8.pm utf8_heavy.pl,)
endef

$(eval $(call BuildPackage,perlbase-utf8))


define Package/perlbase-validate
$(call Package/perlbase-template)
TITLE:=validate perl module
endef

define Package/perlbase-validate/install
$(call perlmod/Install,$(1),validate.pl,)
endef

$(eval $(call BuildPackage,perlbase-validate))


define Package/perlbase-version
$(call Package/perlbase-template)
TITLE:=version perl module
endef

define Package/perlbase-version/install
$(call perlmod/Install,$(1),version.pm,)
endef

$(eval $(call BuildPackage,perlbase-version))


define Package/perlbase-xsloader
$(call Package/perlbase-template)
TITLE:=XSLoader perl module
endef

define Package/perlbase-xsloader/install
$(call perlmod/Install,$(1),XSLoader.pm,)
endef

$(eval $(call BuildPackage,perlbase-xsloader))
