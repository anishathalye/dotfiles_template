##############################
# COMICS specific functions
##############################
function pdf2cbz(){
    IFS=$(echo -en "\n\b");
    PDF_FILE="$1"; shift;

    PDF_FILE_PATH=`readlink -f "$PDF_FILE"`;
    PDF_FILE_NAME=`basename "$PDF_FILE_PATH"`;
    PDF_FILE_DIRNAME=`dirname "$PDF_FILE_PATH"`;

    temp_dir=`mktemp -d`;

    if command -v pdfimages > /dev/null; then
        pdfimages -j "$PDF_FILE_PATH" $temp_dir/page && \
        zip -jr "${PDF_FILE_PATH%.*}.cbz" $temp_dir/* && \
        mv "$PDF_FILE_PATH" "$PDF_FILE_DIRNAME"/."$PDF_FILE_NAME" && \
        rm -Rf $temp_dir;
    else
        echo "Please install pdfimages package"
    fi
}
alias comic_pdf2cbz='pdf2cbz'


function pdf2cbz_all_files_in_dir() {
    IFS=$(echo -en "\n\b");
    for f in `find . -maxdepth 1 -type f -name '*.pdf' -not -path '*/\.*' -exec readlink -f {} \;`;do
        pdf2cbz "$f";
    done;
}
alias comic_pdf2cbz_all_files_in_dir=pdf2cbz_all_files_in_dir


function dirs2cbz() {
    IFS=$(echo -en "\n\b");
    for dir in `find . -mindepth 1 -type d -not -empty`; do
        if find "$dir" -maxdepth 1 -type f -not -ipath '.*\.cbz' -not -ipath '.*\.cbr' -not  -ipath '.*\.pdf'| read f; then
            zip "$(dirname "$dir")/$(basename "$dir").cbz" "$dir"/* && rm -Rf "$dir" ;*/
        fi;
    done
}
alias comic_dirs2cbz=dirs2cbz


function append_folder_name_as_prefix_to_file(){
    IFS=$(echo -en "\n\b");
    local file="$1"; shift;
    mv "${file}" "${PWD##*/} - ${file}"
}
alias comic_add_serie_name='append_folder_name_as_prefix_to_file'

function cbz2pdf(){
    IFS=$(echo -en "\n\b");
    ARCHIVE_FILE="$1"; shift;

    ARCHIVE_FILE_PATH=`readlink -f "$ARCHIVE_FILE"`;
    ARCHIVE_FILE_NAME=`basename "$ARCHIVE_FILE_PATH"`;
    ARCHIVE_FILE_DIRNAME=`dirname "$ARCHIVEFILE_PATH"`;

    temp_dir=`mktemp -d`;

    if ! command -v dwebp > /dev/null; then
        echo "Please install webp package"
        return 1
    fi

    if command -v convert > /dev/null; then
        unzip -j "$ARCHIVE_FILE_PATH" -d $temp_dir
        find $temp_dir/ -name "*.webp" -exec dwebp {} -o {}.jpg \;
        convert $temp_dir/*.jpg "${ARCHIVE_FILE_PATH%.*}.pdf"

        mv "$ARCHIVE_FILE_PATH" "$ARCHIVE_FILE_DIRNAME"/."$ARCHIVE_FILE_NAME" && \
        rm -Rf $temp_dir;
    else
        echo "Please install imagemagick package"
        return 1
    fi
}
alias comic_cbz2pdf='cbz2pdf'

function comic_repack_corrupt_archive2cbz(){
    IFS=$(echo -en "\n\b");
    ARCHIVE_FILE="$1"; shift;

    ARCHIVE_FILE_PATH=`readlink -f "$ARCHIVE_FILE"`;
    ARCHIVE_FILE_NAME=`basename "$ARCHIVE_FILE_PATH"`;
    ARCHIVE_FILE_DIRNAME=`dirname "$ARCHIVEFILE_PATH"`;

    if ! command -v arepack > /dev/null; then
        echo "Please install atool package"
        return 1
    fi

    if [[ "$ARCHIVE_FILE" = *.cbz ]]; then
        arepack "$ARCHIVE_FILE_PATH" "${ARCHIVE_FILE_PATH%.*}.rar"
        mv -f "$ARCHIVE_FILE_PATH" "$ARCHIVE_FILE_DIRNAME"/."$ARCHIVE_FILE_NAME" # archive original 

        arepack "${ARCHIVE_FILE_PATH%.*}.rar" "${ARCHIVE_FILE_PATH%.*}.zip" # reconvert to zip
        rm -f "${ARCHIVE_FILE_PATH%.*}.rar"
        mv -f "${ARCHIVE_FILE_PATH%.*}.zip"  "${ARCHIVE_FILE_PATH%.*}.cbz"
    elif [[ "$ARCHIVE_FILE" = *.cbr ]]; then
        arepack "$ARCHIVE_FILE_PATH" "${ARCHIVE_FILE_PATH%.*}.zip"
        mv -f "$ARCHIVE_FILE_PATH" "$ARCHIVE_FILE_DIRNAME"/."$ARCHIVE_FILE_NAME" && \
          mv -f "${ARCHIVE_FILE_PATH%.*}.zip"  "${ARCHIVE_FILE_PATH%.*}.cbz"
    else
        echo "unknown extension"
    fi

    # remove file from archive
    zip -o -d "${ARCHIVE_FILE_PATH%.*}.cbz" \*crg.gif \*ner0.jpg \*ner0_lee.jpg
}


function comic_repack_all_corrupt_archive2cbz(){
    IFS=$(echo -en "\n\b");
    for f in `find . -maxdepth 1 -type f  -not -path '*/\.*' -exec readlink -f {} \;`;do
        comic_repack_corrupt_archive2cbz "$f";
    done;
}
