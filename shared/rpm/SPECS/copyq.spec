Name:       copyq
Version:    13.0.0
Release:    1%{?dist}
Summary:    Advanced clipboard manager

License:    GPLv3+
URL:        https://hluk.github.io/CopyQ/
Source0:    %{name}-%{version}.tar.gz

%description
CopyQ is advanced clipboard manager with searchable and editable history with
support for image formats, command line control and more.

%prep
%setup -q

%build
cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DPLUGIN_INSTALL_PREFIX=%{_libdir}/%{name}/plugins \
    -DDATA_INSTALL_PREFIX=%{_datadir} \
    -DTRANSLATION_INSTALL_PREFIX=%{_datadir}/%{name}/locale \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_NATIVE_NOTIFICATIONS=OFF

cmake --build build -j $(nproc)

%install
rm -rf %{buildroot}

DESTDIR=%{buildroot} cmake --install build

%find_lang %{name} --with-qt

%check
#desktop-file-validate %{buildroot}%{_datadir}/applications/com.github.hluk.%{name}.desktop
#appstream-util validate-relax --nonet %{buildroot}%{_datadir}/metainfo/com.github.hluk.%{name}.appdata.xml

%files -f %{name}.lang
%doc AUTHORS CHANGES.md HACKING README.md
%license LICENSE
%{_bindir}/%{name}
%{_libdir}/%{name}/
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/metainfo/com.github.hluk.%{name}.appdata.xml
%{_datadir}/applications/com.github.hluk.%{name}.desktop
%dir %{_datadir}/icons/hicolor/*/
%dir %{_datadir}/icons/hicolor/*/apps/
%{_datadir}/icons/hicolor/*/apps/%{name}*.png
%{_datadir}/icons/hicolor/*/apps/%{name}*.svg
%dir %{_datadir}/%{name}/
%dir %{_datadir}/%{name}/locale/
%{_datadir}/%{name}/themes/
%{_mandir}/man1/%{name}.1.*

%changelog
