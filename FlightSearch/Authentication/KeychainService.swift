import Foundation
import Security

// Protocol for Keychain interactions to enable testing and abstraction
protocol KeychainServiceProtocol {
    func save(key: String, data: Data) -> OSStatus
    func retrieve(key: String) -> Data?
    func delete(key: String) -> OSStatus
    func update(key: String, data: Data) -> OSStatus
}

class KeychainService: KeychainServiceProtocol {
    private let serviceIdentifier: String

    // Initialize with a default service identifier, typically the app's bundle ID
    init(serviceIdentifier: String = Bundle.main.bundleIdentifier ?? "com.flights.FlightSearch") {
        self.serviceIdentifier = serviceIdentifier
    }

    /// Saves data to the iOS Keychain for a given key.
    /// If an item with the same key already exists, it will be updated.
    /// - Parameters:
    ///   - key: The key to associate with the data.
    ///   - data: The data to be stored.
    /// - Returns: An OSStatus indicating success or failure.
    func save(key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Item accessible only when the device is unlocked
        ]

        // First, try to update the item. If it doesn't exist, add it.
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        
        if status == errSecItemNotFound {
            // Item not found, so add it
            return SecItemAdd(query as CFDictionary, nil)
        } else {
            // Item updated or other status
            return status
        }
    }
    
    /// Updates existing data in the iOS Keychain for a given key.
    /// - Parameters:
    ///   - key: The key of the item to update.
    ///   - data: The new data to be stored.
    /// - Returns: An OSStatus indicating success or failure.
    func update(key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data
        ]
        
        return SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
    }

    /// Retrieves data from the iOS Keychain for a given key.
    /// - Parameter key: The key associated with the data to retrieve.
    /// - Returns: The retrieved Data, or `nil` if not found or an error occurs.
    func retrieve(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef? // Reference to the retrieved item
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            return item as? Data
        } else if status != errSecItemNotFound {
            print("KeychainService: Error retrieving item for key \(key): \(status)")
        }
        return nil
    }

    /// Deletes data from the iOS Keychain for a given key.
    /// - Parameter key: The key associated with the data to delete.
    /// - Returns: An OSStatus indicating success or failure.
    func delete(key: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("KeychainService: Error deleting item for key \(key): \(status)")
        }
        return status
    }
}
