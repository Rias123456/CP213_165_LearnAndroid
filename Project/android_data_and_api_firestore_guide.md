# การจำค่าตั้งค่าสั้นๆ > SharedPreferences

อ้างอิง: https://developer.android.com/training/data-storage/shared-preferences

## Code

```kotlin
import android.content.Context
import android.content.SharedPreferences

/**
 * SharedPreferencesUtil: เครื่องมือช่วยจัดการการเก็บข้อมูลขนาดเล็กในเครื่อง
 * เหมาะสำหรับ: เก็บสถานะ Login, การตั้งค่า App, หรือคะแนนเกมเบื้องต้น
 */
object SharedPreferencesUtil {

    private const val PREF_NAME = "my_app_prefs"
    private var sharedPreferences: SharedPreferences? = null

    // ฟังก์ชันสำหรับเตรียมการใช้งาน (ต้องเรียกครั้งเดียวใน MainActivity หรือ Application)
    fun init(context: Context) {
        if (sharedPreferences == null) {
            sharedPreferences = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        }
    }

    // --- ฟังก์ชันสำหรับ "บันทึก" ข้อมูล (Save) ---

    fun saveString(key: String, value: String) {
        sharedPreferences?.edit()?.putString(key, value)?.apply()
    }

    fun saveInt(key: String, value: Int) {
        sharedPreferences?.edit()?.putInt(key, value)?.apply()
    }

    fun saveBoolean(key: String, value: Boolean) {
        sharedPreferences?.edit()?.putBoolean(key, value)?.apply()
    }

    // --- ฟังก์ชันสำหรับ "ดึง" ข้อมูล (Get) ---

    fun getString(key: String, defaultValue: String = ""): String {
        return sharedPreferences?.getString(key, defaultValue) ?: defaultValue
    }

    fun getInt(key: String, defaultValue: Int = 0): Int {
        return sharedPreferences?.getInt(key, defaultValue) ?: defaultValue
    }

    fun getBoolean(key: String, defaultValue: Boolean = false): Boolean {
        return sharedPreferences?.getBoolean(key, defaultValue) ?: defaultValue
    }

    // --- ฟังก์ชันสำหรับ "ลบ" ข้อมูล (Delete) ---

    fun remove(key: String) {
        sharedPreferences?.edit()?.remove(key)?.apply()
    }

    fun clearAll() {
        sharedPreferences?.edit()?.clear()?.apply()
    }
}
```

## Example

เพื่อให้เห็นผลลัพธ์ว่า "ข้อมูลไม่หายแม้ปิดแอพ" ให้ลองทำตามขั้นตอนนี้ใน `MainActivity.kt`:

### 1) เรียกคำสั่ง Init ใน `onCreate`

ก่อนจะเรียกใช้ต้องบอกให้แอพรู้จักไฟล์นี้ก่อน:

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // 1. เชื่อมต่อเครื่องมือเข้ากับ Context ของแอพ
    SharedPreferencesUtil.init(this)
}
```

### 2) ทดลองบันทึกและอ่านค่า

ให้ลองเขียนโค้ดเพื่อทดสอบดูในปุ่มกดหรือตอนเปิดแอพ:

```kotlin
// การบันทึกค่า (เช่น เมื่อกดปุ่ม Save)
SharedPreferencesUtil.saveString("user_name", "xxx")
SharedPreferencesUtil.saveBoolean("is_dark_mode", true)

// การดึงค่ามาใช้งาน (เช่น เมื่อเปิดแอพขึ้นมาใหม่)
val name = SharedPreferencesUtil.getString("user_name")
val darkMode = SharedPreferencesUtil.getBoolean("is_dark_mode")

println("สวัสดีคุณ: $name, สถานะ Dark Mode: $darkMode")
```

---

# การคุยกับ Server ผ่าน API

ตัวอย่าง endpoint: https://pokeapi.co/api/v2/pokedex/2/

## Code

### 1) การเตรียม Gradle (Dependencies)

เพิ่ม Library ใน `build.gradle.kts` (Module `:app`) :

```kotlin
dependencies {
    // Retrofit สำหรับคุยกับ Server
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    // Converter สำหรับแปลง JSON เป็น Data Class (Gson)
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")

    // Lifecycle & ViewModel สำหรับ Compose
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.0")
}
```

### 2) ไฟล์จัดการ API (`PokemonApi.kt`)

ไฟล์เดียวที่จัดการทุกอย่างเกี่ยวกับ Network:

```kotlin
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

// --- ส่วนที่ 1: Data Model (โครงสร้างข้อมูลตาม JSON) ---
// โครงสร้าง JSON ของ PokeAPI: https://pokeapi.co/api/v2/pokedex/2/
data class PokedexResponse(
    val pokemon_entries: List<PokemonEntry>
)

data class PokemonEntry(
    val entry_number: Int,
    val pokemon_species: PokemonSpecies
)

data class PokemonSpecies(
    val name: String,
    val url: String
)

// --- ส่วนที่ 2: API Interface (เมนูสั่งอาหาร) ---
interface PokemonApiService {
    @GET("pokedex/2/") // Endpoint ที่เราจะเรียก
    suspend fun getKantoPokedex(): PokedexResponse
}

// --- ส่วนที่ 3: Singleton Instance (ตัวจัดการการเชื่อมต่อ) ---
object PokemonNetwork {
    private const val BASE_URL = "https://pokeapi.co/api/v2/"

    // สร้างตัว Retrofit เพียงครั้งเดียวเพื่อประหยัดทรัพยากร
    val api: PokemonApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create()) // ตัวแปลง JSON
            .build()
            .create(PokemonApiService::class.java)
    }
}
```

### 3) ส่วนการเรียกใช้งาน (ViewModel + UI)

สอนการเรียกใช้ผ่าน MVVM แบบง่าย ๆ:

#### 3.1 ViewModel (ตัวกลางคุยกับ API)

```kotlin
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PokemonViewModel : ViewModel() {

    // State สำหรับบอกสถานะของหน้าจอ (Loading, Success, Error)
    // ในที่นี้เอาแบบง่ายสุดคือเก็บ List ของโปเกมอน
    private val _pokemonList = MutableStateFlow<List<PokemonEntry>>(emptyList())
    val pokemonList = _pokemonList.asStateFlow()

    // ฟังก์ชันยิง API
    fun fetchPokemon() {
        viewModelScope.launch {
            try {
                // เรียกใช้ API จากไฟล์ PokemonApi.kt ที่เราสร้าง
                val response = PokemonNetwork.api.getKantoPokedex()

                // อัปเดตข้อมูลใส่ State
                _pokemonList.value = response.pokemon_entries

            } catch (e: Exception) {
                // จัดการ Error (เช่น Log หรือโชว์ Toast)
                e.printStackTrace()
            }
        }
    }
}
```

#### 3.2 Compose UI (หน้าจอแสดงผล)

แสดงผล List แบบง่าย ๆ:

```kotlin
val pokemonList by viewModel.pokemonList.collectAsState()
```

---

# Cloud Firestore บน Firebase

ยืดหยุ่น ใช้ง่าย และเป็น NoSQL (ไม่ต้องสร้างตารางยุ่งยากเหมือน SQL)

## Setup

## EP : Firebase Cloud Firestore – ฐานข้อมูลลอยฟ้า

### Step 1: ตั้งไข่บน Firebase Console

ก่อนเขียนโค้ด ต้องไปสร้าง "บ้าน" ให้ข้อมูลเราอยู่ก่อน

1. **สมัคร/ล็อกอิน:** เข้า [console.firebase.google.com](https://console.firebase.google.com/)
2. **Create Project:**
   - ตั้งชื่อโปรเจกต์ (เช่น `MyClassroomApp`)
   - เลือก **Disable Google Analytics** เพื่อเริ่มไวขึ้น
3. **Add App (เชื่อมแอพ Android):**
   - คลิกไอคอน **Android**
   - **สำคัญ:** ช่อง **Android package name** ต้องตรงกับใน `build.gradle` ของโปรเจกต์
   - กด **Register app**
4. **Download Config File:**
   - ดาวน์โหลดไฟล์ `google-services.json`
   - นำไปวางไว้ในโฟลเดอร์ `app/`
5. **เปิดใช้งาน Firestore:**
   - เมนูซ้าย **Build** -> **Firestore Database**
   - กด **Create database**
   - เลือก Location (แนะนำ `asia-southeast1`)
   - Rules: เลือก **Start in test mode**

### Step 2: เตรียม Gradle (Dependencies)

#### 1) `build.gradle.kts` (Project Level)

```kotlin
plugins {
    // เพิ่ม Google Services Plugin
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

#### 2) `build.gradle.kts` (Module :app)

```kotlin
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    // Firebase BOM
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))

    // Cloud Firestore Library
    implementation("com.google.firebase:firebase-firestore")
}
```

### Step 3: สร้าง `FirestoreHelper.kt`

```kotlin
import android.util.Log
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query

// Data Model ง่าย ๆ สำหรับทดสอบ (เช่น สมุดเยี่ยมชม)
data class GuestMessage(
    val id: String = "",
    val name: String = "",
    val message: String = "",
    val timestamp: Long = System.currentTimeMillis()
)

object FirestoreHelper {
    // เข้าถึงตัว Database
    private val db = FirebaseFirestore.getInstance()

    // ชื่อ Collection
    private const val COLLECTION_NAME = "guestbook"

    // 1) ฟังก์ชันเพิ่มข้อมูล (Add)
    fun addMessage(name: String, message: String, onSuccess: () -> Unit) {
        val newMessage = GuestMessage(
            name = name,
            message = message
        )

        db.collection(COLLECTION_NAME)
            .add(newMessage)
            .addOnSuccessListener {
                Log.d("Firestore", "เพิ่มข้อมูลสำเร็จ ID: ${it.id}")
                onSuccess()
            }
            .addOnFailureListener { e ->
                Log.e("Firestore", "พังยับ: $e")
            }
    }

    // 2) ฟังก์ชันดึงข้อมูลแบบ Realtime (Listen)
    fun listenToMessages(onUpdate: (List<GuestMessage>) -> Unit) {
        db.collection(COLLECTION_NAME)
            .orderBy("timestamp", Query.Direction.DESCENDING)
            .addSnapshotListener { value, error ->
                if (error != null) {
                    Log.e("Firestore", "ฟังข้อมูลล้มเหลว", error)
                    return@addSnapshotListener
                }

                val messages = ArrayList<GuestMessage>()
                for (doc in value!!) {
                    val msg = doc.toObject(GuestMessage::class.java).copy(id = doc.id)
                    messages.add(msg)
                }
                onUpdate(messages)
            }
    }

    // 3) ฟังก์ชันลบข้อมูล (Delete)
    fun deleteMessage(docId: String) {
        db.collection(COLLECTION_NAME).document(docId).delete()
    }
}
```

### Step 4: วิธีเรียกใช้งานใน ViewModel

สร้าง `GuestbookViewModel.kt`:

```kotlin
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class GuestbookViewModel : ViewModel() {

    private val _messages = MutableStateFlow<List<GuestMessage>>(emptyList())
    val messages = _messages.asStateFlow()

    init {
        // ทันทีที่เปิดหน้านี้ ให้เริ่ม "ฟัง" ข้อมูลจาก Firebase
        FirestoreHelper.listenToMessages { updatedList ->
            _messages.value = updatedList
        }
    }

    fun sendMessage(name: String, text: String) {
        if (name.isNotBlank() && text.isNotBlank()) {
            FirestoreHelper.addMessage(name, text) {
                // ทำอะไรต่อหลังส่งเสร็จไหม? (เช่น เคลียร์ช่องพิมพ์)
            }
        }
    }

    fun deleteMessage(id: String) {
        FirestoreHelper.deleteMessage(id)
    }
}
```
