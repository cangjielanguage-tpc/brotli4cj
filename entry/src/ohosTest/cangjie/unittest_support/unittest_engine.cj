package ohos_app_cangjie_entry_test.unittest_support

import ohos.test_runner.TestRunner
import ohos.hilog.HilogChannel
import ohos.ability_delegator_registry.AbilityDelegatorRegistry
import std.unittest.XmlReporter
import std.fs.Path
import std.fs.Directory
import std.collection.filter
import std.fs.FileInfo
import std.collection.first
import std.fs.File
import std.collection.forEach
import std.convert.Parsable
import ohos.bundle_manager.BundleManager
import ohos.bundle_manager.BundleFlag
import std.collection.any
import std.collection.HashMap
import std.unittest.TestClass
import std.collection.ArrayList
import std.unittest.TestSuite
import ohos.ability.Want
import std.process.Process
import ohos.ui_test.UITest
import std.unittest.common.Configuration

@When[coverage == "true"]
foreign func __gcov_dump(): Unit

@When[coverage == "true"]
public func gcov_dump(coveragePath: String): Unit {
    let logger = HilogChannel(0, 0, "CangjieTest")
    logger.info("execute test with coverage")
    unsafe { __gcov_dump() }
    let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
    abilityDelegator.print("GENERATE_COVERAGE: ${coveragePath}")
}

@When[coverage == "false"]
public func gcov_dump(coveragePath: String): Unit {
    let logger = HilogChannel(0, 0, "CangjieTest")
    logger.info("execute test without coverage")
}

public func registerTestSuite(testClassInstanceGenerator: () -> TestClass): Unit {
    OpenHarmonyTestRunner
        .testClassInstanceGenerators
        .add(testClassInstanceGenerator)
}

public class OpenHarmonyTestRunner <: TestRunner {
    private static let logger = HilogChannel(0, 0, "CangjieTest")
    public static let testSuiteMap = HashMap<String, TestSuite>()
    public static let testClassInstanceGenerators = ArrayList<() -> TestClass>()
    private static func getDetailedInfoOf(e: Exception): String {
        let sb = StringBuilder("exception: ${e.toString()}\n")
        e.getStackTrace() |>
            forEach {
            s => sb.append("         at ${s.declaringClass}.${s.methodName}(${s.fileName}:${s.lineNumber})\n")
        }
        sb.toString()
    }

    private func executeTestClass(testClassName: String): Unit {
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        logger.info("EXECUTE_CLASS_START: \"${testClassName}\"")
        abilityDelegator.print("EXECUTE_CLASS_START: \"${testClassName}\"")
        let testSuite = match (OpenHarmonyTestRunner
            .testSuiteMap
            .get(testClassName)) {
            case None => return
            case Some(testClassInstanceGenerator) => testClassInstanceGenerator
        }

        testSuite
            .runTests()
            .reportTo(XmlReporter(Path("/data/storage/el1/base")))

        let testReportXmlFileName = "test-default.${testClassName}.xml"
        match (Directory.readFrom("/data/storage/el1/base/tests") |>
            filter {fileInfo => fileInfo.name == testReportXmlFileName} |> first) {
            case None => logger.error("${testReportXmlFileName} not found.")
            case Some(testReportXmlFileInfo) =>
                let testReportXmlFilePath = testReportXmlFileInfo.path
                let testReportXmlFileContent = File.readFrom(testReportXmlFilePath)
                let xmlReport = String.fromUtf8(testReportXmlFileContent)
                logger.info("XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                logger.info(xmlReport)
                abilityDelegator.print("XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                abilityDelegator.print(xmlReport)
                logger.info("EXECUTE_CLASS_END: \"${testClassName}\"")
                abilityDelegator.print("EXECUTE_CLASS_END: \"${testClassName}\"")
                reportTestReport("test-default.${testClassName}.xml")
        }
    }
    private func executeAllTestClasses(): Unit {
        for (testClassName in OpenHarmonyTestRunner
                .testSuiteMap
                .keys()) {
            executeTestClass(testClassName)
        }
    }
    private func executeTestCase(testClassName: String, testCaseName: String): Unit {
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        abilityDelegator.print("EXECUTE_CLASS_START: \"${testClassName}\"")
        logger.info("EXECUTE_METHOD_START: \"${testClassName}#${testCaseName}\"")
        let testSuite = match (OpenHarmonyTestRunner
            .testSuiteMap
            .get(testClassName)) {
            case None => return
            case Some(testClassInstanceGenerator) => testClassInstanceGenerator
        }
        let configuration = Configuration()
        configuration.setByName("filter", "${testClassName}.${testCaseName}")
        testSuite
            .runTests(configuration)
            .reportTo(XmlReporter(Path("/data/storage/el1/base")))

        let testReportXmlFileName = "test-default.${testClassName}.xml"
        match (Directory.readFrom("/data/storage/el1/base/tests") |>
            filter {fileInfo => fileInfo.name == testReportXmlFileName} |> first) {
            case None => logger.error("${testReportXmlFileName} not found.")
            case Some(testReportXmlFileInfo) =>
                let testReportXmlFilePath = testReportXmlFileInfo.path
                let testReportXmlFileContent = File.readFrom(testReportXmlFilePath)
                let xmlReport = String.fromUtf8(testReportXmlFileContent)
                logger.info("XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                logger.info(xmlReport)
                abilityDelegator.print("XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                abilityDelegator.print(xmlReport)
                logger.info("EXECUTE_METHOD_END: \"${testClassName}#${testCaseName}\"")
                abilityDelegator.print("EXECUTE_CLASS_END: \"${testClassName}\"")
                reportTestReport("test-default.${testClassName}.xml")
        }
    }
    private func reportTestReport(testReportName: String): Unit {
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        let abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments()
        let bundleName = abilityDelegatorArguments.bundleName
        abilityDelegator.print("REPORT_TEST_RESULT: /data/app/el1/100/base/${bundleName}/tests/${testReportName}")
    }
    public override func onPrepare(): Unit {
        logger.info("OpenHarmonyTestRunner onPrepare")
        for (testClassInstanceGenerator in OpenHarmonyTestRunner.testClassInstanceGenerators) {
            let testClassInstance = try {
                testClassInstanceGenerator()
            } catch (e: Exception) {
                logger.error("exception occurred during testsuite generation:\n${getDetailedInfoOf(e)}")
                continue
            }
            let testSuite = testClassInstance.asTestSuite()
            let testSuiteName = testSuite.name
            logger.info("Registering TestSuite ${testSuiteName}")
            OpenHarmonyTestRunner
                .testSuiteMap
                .add(testSuiteName, testSuite)
        }
    }
    public override func onRun(): Unit {
        logger.info("OpenHarmonyTestRunner onRun")
        let abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments()
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        UITest.setup()
        logger.info("bundleName = ${abilityDelegatorArguments.bundleName}")
        logger.info("abilityDelegatorArguments.testRunnerClassName = ${abilityDelegatorArguments.testRunnerClassName}")
        logger.info("abilityDelegatorArguments.testCaseNames = ${abilityDelegatorArguments.testCaseNames}")
        logger.info("abilityDelegatorArguments.parameters = ${abilityDelegatorArguments.parameters}")
        logger.info("Started running tests.")
        abilityDelegator.print("OpenHarmonyTestRunner onRun")
        let parameters = abilityDelegatorArguments.parameters
        let bundleName = abilityDelegatorArguments.bundleName
        let bundleInfo = BundleManager.getBundleInfoForSelf(
            BundleFlag
                .GET_BUNDLE_INFO_WITH_HAP_MODULE
                .getValue() | BundleFlag
                .GET_BUNDLE_INFO_WITH_APPLICATION
                .getValue())
        let moduleName = match (parameters.get("-m")) {
            case None =>
                abilityDelegator.finishTest("Module name was not specified.", -1)
                return
            case Some(moduleName) =>
                if (bundleInfo.hapModulesInfo |> any {hapModuleInfo => hapModuleInfo.name == moduleName}) {
                    moduleName
                } else {
                    abilityDelegator.finishTest(
                        "No module with name \"${moduleName}\" was found in bundle ${bundleName}.", -1)
                    return
                }
        }
        let abilityName = match (bundleInfo.hapModulesInfo |> filter {hapModuleInfo => hapModuleInfo.name == moduleName} |>
            first) {
            case None =>
                abilityDelegator.finishTest("No module with name \"${moduleName}\" was found in bundle ${bundleName}.",
                    -1)
                return
            case Some(hapModuleInfo) =>
                let mainElementName = hapModuleInfo.mainElementName
                logger.info("mainElementName = ${mainElementName}")
                mainElementName
        }
        let want = Want(bundleName: bundleName, moduleName: moduleName, abilityName: abilityName)
        abilityDelegator
            .startAbility(want)
            .get()
        let timeOut = match (parameters.get("-s timeout")) {
            case None => None<Int64>
            case Some(timeOutText) => match (Int64.tryParse(timeOutText)) {
                case None =>
                    abilityDelegator.finishTest("The parameter \"timeout\": ${timeOutText} is invalid", -1)
                    return
                case Some(timeOutValue) => timeOutValue
            }
        }
        spawn {
            try {
                match (parameters.get("-s class")) {
                    case None => executeAllTestClasses()
                    case Some(text) => text.split(",", removeEmpty: true) |>
                        forEach {
                        t: String =>
                        let pair = t.split("#", removeEmpty: true)
                        let testClassName = match (pair.get(0)) {
                            case None => return
                            case Some(text) => text.trimAscii()
                        }
                        match (pair.get(1)) {
                            case None => executeTestClass(testClassName)
                            case Some(testCaseName) => executeTestCase(testClassName, testCaseName)
                        }
                    }
                }
            } catch (e: Exception) {
                logger.error("an exception occurred:\n${getDetailedInfoOf(e)}")
            }
            Process
                .current
                .setEnv("GCOV_PREFIX", "/data/storage/el1/base/cov")
            gcov_dump("/data/app/el1/100/base/${bundleName}/cov/")

            abilityDelegator.finishTest("Test finished.", 0)
        }
    }
}

let _ = TestRunner.registerCreator("OpenHarmonyTestRunner") {OpenHarmonyTestRunner()}
