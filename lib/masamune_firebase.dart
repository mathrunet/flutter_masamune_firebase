// Copyright 2020 mathru. All rights reserved.

/// Masamune firebase framework library.
///
/// To use, import `package:masamune_firebase/masamune_firebase.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.firebase;

import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masamune_flutter/masamune_flutter.dart';
import 'package:masamune_form/masamune_form.dart';
export 'package:masamune_flutter/masamune_flutter.dart';
export 'package:masamune_form/masamune_form.dart';

part 'config/appconfigdocument.dart';
part 'config/remoteconfigdocument.dart';

part 'interface/ifirestorechangelistener.dart';
part 'interface/ifirestorecollection.dart';

part 'core/firestorequerytype.dart';
part 'core/typedef.dart';
part 'core/firestorecollectionlistener.dart';
part 'core/firestorequery.dart';
part 'core/firestoremeta.dart';

part 'firebase/firebase.dart';

part 'firestore/ifirestorecollectionlistener.dart';
part 'firestore/firestoredocument.dart';
part 'firestore/firestorecollection.dart';
part 'firestore/searchablefirestorecollection.dart';

part 'auth/firestoreauth.dart';
part 'auth/authprovideroptions.dart';
part 'auth/emailandpasswordauth.dart';
part 'auth/anonymouslyauth.dart';

part 'storage/firestorestorage.dart';

part 'dynamiclink/firestoredynamiclinkuri.dart';

part 'widget/uiloginformdialog.dart';
part 'widget/uiloginform.dart';
part 'widget/uiauth.dart';
part 'widget/uiauthdialog.dart';
part 'widget/uiappconfig.dart';
part 'widget/accountbutton.dart';

part 'widget/reauth.dart';
part 'widget/changeemail.dart';
part 'widget/changepassword.dart';

part 'firestore/firestorefolderstructureutility.dart';
