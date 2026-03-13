@preconcurrency import FirebaseFirestore

final class FirestoreService: Sendable {
    static let shared = FirestoreService()

    let db: Firestore

    private init() {
        db = Firestore.firestore()
    }

    func collection(_ path: String) -> CollectionReference {
        db.collection(path)
    }
}
