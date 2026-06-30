/*!
 * Copyright (c) 2026 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package io.emeric.mobilesharing;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.provider.DocumentsContract.Document;
import android.provider.DocumentsContract.Root;
import android.provider.DocumentsProvider;
import android.util.Log;
import android.webkit.MimeTypeMap;

/*
 * MobileSharing: optional Storage Access Framework (SAF) DocumentsProvider.
 *
 * Exposes ONE app-owned directory (typically <app files>/MobileSharing/shared)
 * to other apps through the system file picker and the "open document tree" flow,
 * so a chosen folder can be browsed (and, when writable, modified) from any app that uses SAF.
 *
 * Design notes:
 *  - Fully optional & runtime toggled. The provider is always declared in the manifest, but it
 *    is INERT until enabled: queryRoots() returns no root (so nothing shows up in any picker)
 *    and every document lookup is refused while sharing is disabled. The host turns it on/off at
 *    runtime through MobileSharing.setDocumentProviderEnabled() on the C++/QML side.
 *  - Config lives in SharedPreferences (written by QShareUtils.setDocumentProvider()). The Android
 *    system may spin up the app process just to query this provider (e.g. the picker enumerating
 *    roots) before any Qt/QML is running, so the state must be readable without the rest of the
 *    app being initialized. SharedPreferences gives us exactly that.
 *  - Read/write decision stays on the MobileSharing side via the 'writable' pref: when false the
 *    folder is exposed read-only; when true the provider also honors create / write / delete /
 *    rename. (The C++ side currently forces 'writable' off, so this stays dormant until flipped.)
 *  - Document ids are absolute file paths. getFileForDocId() canonicalizes and confirms the file
 *    stays within the configured root, so a crafted/stale id can never escape the shared folder.
 */
public class QShareDocumentProvider extends DocumentsProvider
{
    private static final String TAG = "QShareDocProvider";

    // Shared with QShareUtils.setDocumentProvider() (kept in sync there).
    private static final String PREFS    = "MobileSharingDocProvider";
    private static final String KEY_ENABLED  = "enabled";
    private static final String KEY_ROOT_DIR = "rootDir";
    private static final String KEY_WRITABLE = "writable";
    private static final String KEY_TITLE    = "title";

    private static final String[] DEFAULT_ROOT_PROJECTION = new String[]{
        Root.COLUMN_ROOT_ID,
        Root.COLUMN_FLAGS,
        Root.COLUMN_TITLE,
        Root.COLUMN_DOCUMENT_ID,
        Root.COLUMN_ICON,
    };

    private static final String[] DEFAULT_DOCUMENT_PROJECTION = new String[]{
        Document.COLUMN_DOCUMENT_ID,
        Document.COLUMN_MIME_TYPE,
        Document.COLUMN_DISPLAY_NAME,
        Document.COLUMN_LAST_MODIFIED,
        Document.COLUMN_FLAGS,
        Document.COLUMN_SIZE,
    };

    @Override
    public boolean onCreate() {
        return true;
    }

    private SharedPreferences prefs() {
        return getContext().getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    // -------------------------------------------------------------------------
    // Roots
    // -------------------------------------------------------------------------

    @Override
    public Cursor queryRoots(String[] projection) {
        final MatrixCursor result =
                new MatrixCursor(projection != null ? projection : DEFAULT_ROOT_PROJECTION);

        final SharedPreferences p = prefs();

        // Optional feature: while disabled we advertise NO root, so the folder is invisible in
        // every picker and the whole provider behaves as if it did not exist.
        if (!p.getBoolean(KEY_ENABLED, false)) {
            return result;
        }

        final String rootPath = p.getString(KEY_ROOT_DIR, "");
        final File root = new File(rootPath);
        if (rootPath.isEmpty() || !root.isDirectory()) {
            Log.w(TAG, "queryRoots: enabled but root is not a directory: " + rootPath);
            return result;
        }

        final String title = p.getString(KEY_TITLE, "Shared");
        final boolean writable = p.getBoolean(KEY_WRITABLE, false);

        // FLAG_SUPPORTS_IS_CHILD lets SAF offer this root for ACTION_OPEN_DOCUMENT_TREE, so an
        // app can take persistable access to the whole subtree (durable directory sharing).
        int flags = Root.FLAG_LOCAL_ONLY | Root.FLAG_SUPPORTS_IS_CHILD;
        // When writable, advertise creation at the root level.
        if (writable) {
            flags |= Root.FLAG_SUPPORTS_CREATE;
        }

        final MatrixCursor.RowBuilder row = result.newRow();
        row.add(Root.COLUMN_ROOT_ID, rootPath);
        row.add(Root.COLUMN_DOCUMENT_ID, rootPath); // root document id == the directory path
        row.add(Root.COLUMN_TITLE, title);
        row.add(Root.COLUMN_FLAGS, flags);
        row.add(Root.COLUMN_ICON, getContext().getApplicationInfo().icon);
        return result;
    }

    @Override
    public boolean isChildDocument(String parentDocumentId, String documentId) {
        // Document ids are absolute paths, so containment is a simple prefix test. Required for
        // FLAG_SUPPORTS_IS_CHILD / persisted tree permissions to work.
        if (parentDocumentId == null || documentId == null) return false;
        return documentId.equals(parentDocumentId)
                || documentId.startsWith(parentDocumentId + File.separator);
    }

    // -------------------------------------------------------------------------
    // Documents (read)
    // -------------------------------------------------------------------------

    @Override
    public Cursor queryDocument(String documentId, String[] projection) throws FileNotFoundException {
        final MatrixCursor result =
                new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        includeFile(result, getFileForDocId(documentId));
        return result;
    }

    @Override
    public Cursor queryChildDocuments(String parentDocumentId, String[] projection, String sortOrder)
            throws FileNotFoundException {
        final MatrixCursor result =
                new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        final File parent = getFileForDocId(parentDocumentId);
        final File[] children = parent.listFiles();
        if (children != null) {
            for (File child : children) {
                includeFile(result, child);
            }
        }
        return result;
    }

    @Override
    public ParcelFileDescriptor openDocument(String documentId, String mode, CancellationSignal signal)
            throws FileNotFoundException {
        final File file = getFileForDocId(documentId);
        final int accessMode = ParcelFileDescriptor.parseMode(mode);

        // Writes are gated on the 'writable' pref (and we only advertise write flags when writable),
        // so refuse any write/append/truncate access while read-only.
        if (accessMode != ParcelFileDescriptor.MODE_READ_ONLY && !isWritable()) {
            throw new FileNotFoundException("QShareDocumentProvider is read-only: " + mode);
        }
        // ParcelFileDescriptor.open() honors the parsed mode for a plain on-disk file.
        return ParcelFileDescriptor.open(file, accessMode);
    }

    // -------------------------------------------------------------------------
    // Documents (write) — only reached when the 'writable' pref is set, since we advertise the
    // matching flags only then; each method still re-checks via requireWritable() as a guard.
    // -------------------------------------------------------------------------

    @Override
    public String createDocument(String parentDocumentId, String mimeType, String displayName)
            throws FileNotFoundException {
        final File parent = getFileForDocId(parentDocumentId);
        requireWritable();

        final File target = resolveCollision(parent, displayName);
        try {
            if (Document.MIME_TYPE_DIR.equals(mimeType)) {
                if (!target.mkdir()) {
                    throw new FileNotFoundException("could not create directory: " + target);
                }
            } else if (!target.createNewFile()) {
                throw new FileNotFoundException("could not create file: " + target);
            }
        } catch (IOException e) {
            throw new FileNotFoundException("create failed: " + e.getMessage());
        }

        notifyChildrenChanged(parent);
        return target.getAbsolutePath();
    }

    @Override
    public void deleteDocument(String documentId) throws FileNotFoundException {
        final File file = getFileForDocId(documentId);
        requireWritable();

        if (!deleteRecursively(file)) {
            throw new FileNotFoundException("delete failed: " + documentId);
        }
        final File parent = file.getParentFile();
        if (parent != null) {
            notifyChildrenChanged(parent);
        }
    }

    @Override
    public void removeDocument(String documentId, String parentDocumentId) throws FileNotFoundException {
        // We expose a plain tree where each document has a single parent, so "remove from this
        // parent" is just a delete.
        deleteDocument(documentId);
    }

    @Override
    public String renameDocument(String documentId, String displayName) throws FileNotFoundException {
        final File file = getFileForDocId(documentId);
        requireWritable();

        final File parent = file.getParentFile();
        if (parent == null) {
            throw new FileNotFoundException("cannot rename the root: " + documentId);
        }
        final File dest = resolveCollision(parent, displayName);
        if (!file.renameTo(dest)) {
            throw new FileNotFoundException("rename failed: " + documentId);
        }

        notifyChildrenChanged(parent);
        return dest.getAbsolutePath(); // the document id is the path, so it changed
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    // Fill one document row from a File. Write/delete/rename/create flags are advertised only when
    // the 'writable' pref is set; otherwise the document is exposed read-only.
    private void includeFile(MatrixCursor result, File file) {
        int flags = 0;
        if (isWritable()) {
            if (file.isDirectory()) {
                flags |= Document.FLAG_DIR_SUPPORTS_CREATE;
            } else {
                flags |= Document.FLAG_SUPPORTS_WRITE;
            }
            flags |= Document.FLAG_SUPPORTS_DELETE | Document.FLAG_SUPPORTS_RENAME;
        }

        final MatrixCursor.RowBuilder row = result.newRow();
        row.add(Document.COLUMN_DOCUMENT_ID, file.getAbsolutePath());
        row.add(Document.COLUMN_DISPLAY_NAME, file.getName());
        row.add(Document.COLUMN_SIZE, file.length());
        row.add(Document.COLUMN_MIME_TYPE, getMimeType(file));
        row.add(Document.COLUMN_LAST_MODIFIED, file.lastModified());
        row.add(Document.COLUMN_FLAGS, flags);
    }

    // Resolve a document id (absolute path) to a File, refusing anything while sharing is disabled
    // or anything that resolves outside the configured root directory.
    private File getFileForDocId(String docId) throws FileNotFoundException {
        final SharedPreferences p = prefs();
        if (!p.getBoolean(KEY_ENABLED, false)) {
            throw new FileNotFoundException("directory sharing is disabled");
        }
        final String rootPath = p.getString(KEY_ROOT_DIR, "");
        if (rootPath.isEmpty()) {
            throw new FileNotFoundException("no shared directory configured");
        }

        final File file = new File(docId);
        try {
            final String canonicalRoot = new File(rootPath).getCanonicalPath();
            final String canonicalFile = file.getCanonicalPath();
            if (!canonicalFile.equals(canonicalRoot)
                    && !canonicalFile.startsWith(canonicalRoot + File.separator)) {
                throw new FileNotFoundException("document is outside the shared root: " + docId);
            }
        } catch (IOException e) {
            throw new FileNotFoundException("cannot resolve document path: " + docId);
        }
        return file;
    }

    private boolean isWritable() {
        return prefs().getBoolean(KEY_WRITABLE, false);
    }

    // SAF only calls the write ops when we advertise the matching flags, but this also guards any
    // direct provider call (e.g. a stale URI permission held across a writable -> read-only switch).
    private void requireWritable() throws FileNotFoundException {
        if (!isWritable()) {
            throw new FileNotFoundException("QShareDocumentProvider is read-only");
        }
    }

    // Pick a non-colliding file in parent, appending " (1)", " (2)", ... before the extension.
    private static File resolveCollision(File parent, String displayName) {
        File candidate = new File(parent, displayName);
        if (!candidate.exists()) {
            return candidate;
        }

        String base = displayName;
        String ext = "";
        final int dot = displayName.lastIndexOf('.');
        if (dot > 0) { // dot > 0 so dotfiles (".keep") keep their whole name as base
            base = displayName.substring(0, dot);
            ext = displayName.substring(dot);
        }
        for (int i = 1; ; i++) {
            candidate = new File(parent, base + " (" + i + ")" + ext);
            if (!candidate.exists()) {
                return candidate;
            }
        }
    }

    // Depth-first delete, so a non-empty directory can be removed too.
    private static boolean deleteRecursively(File file) {
        if (file.isDirectory()) {
            final File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) {
                    if (!deleteRecursively(child)) {
                        return false;
                    }
                }
            }
        }
        return file.delete();
    }

    // Tell SAF the children of 'parent' changed, so any open picker refreshes.
    private void notifyChildrenChanged(File parent) {
        final String authority = getContext().getPackageName() + ".documents";
        final Uri uri = DocumentsContract.buildChildDocumentsUri(authority, parent.getAbsolutePath());
        getContext().getContentResolver().notifyChange(uri, null);
    }

    private static String getMimeType(File file) {
        if (file.isDirectory()) {
            return Document.MIME_TYPE_DIR;
        }
        final String name = file.getName();
        final int dot = name.lastIndexOf('.');
        if (dot >= 0 && dot < name.length() - 1) {
            final String ext = name.substring(dot + 1).toLowerCase();
            final String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
            if (mime != null) {
                return mime;
            }
        }
        return "application/octet-stream";
    }
}
