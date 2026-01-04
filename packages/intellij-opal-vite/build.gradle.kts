plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.9.21"
    id("org.jetbrains.intellij") version "1.17.1"
}

group = "com.opalvite"
version = "0.3.8"

repositories {
    mavenCentral()
}

intellij {
    version.set("2024.1")
    type.set("IU") // IntelliJ IDEA Ultimate (required for Ruby plugin)
    plugins.set(listOf(
        "org.jetbrains.plugins.ruby:241.14494.240",
        "com.redhat.devtools.lsp4ij:0.5.0"
    ))
}

tasks {
    withType<JavaCompile> {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions.jvmTarget = "17"
    }

    patchPluginXml {
        sinceBuild.set("241")
        untilBuild.set("243.*")
        changeNotes.set("""
            <h2>0.3.8</h2>
            <ul>
                <li>Add Vim/Neovim plugin support</li>
                <li>Add Pull Diagnostics support for Neovim 0.11+</li>
                <li>Fix buffer reload errors in Neovim plugin</li>
            </ul>
            <h2>0.3.7</h2>
            <ul>
                <li>Initial release</li>
                <li>LSP integration with opal-language-server</li>
                <li>Syntax highlighting for Opal-specific Ruby constructs</li>
                <li>Live templates for Stimulus controllers and OpalVite concerns</li>
                <li>Diagnostics for Opal-incompatible Ruby patterns</li>
            </ul>
        """.trimIndent())
    }

    signPlugin {
        certificateChain.set(System.getenv("CERTIFICATE_CHAIN"))
        privateKey.set(System.getenv("PRIVATE_KEY"))
        password.set(System.getenv("PRIVATE_KEY_PASSWORD"))
    }

    publishPlugin {
        token.set(System.getenv("PUBLISH_TOKEN"))
    }
}
