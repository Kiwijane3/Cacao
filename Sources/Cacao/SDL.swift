//
//  SDL.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/7/17.
//

import Foundation
import CSDL2
import SDL

// MARK: - Main SDL run loop

@_silgen_name("SDLEventRun")
internal func SDLEventRun() {
    
    #if os(macOS) || swift(>=4.0)
    assert(Thread.current.isMainThread, "Should only be called from main thread")
    #endif
    
    do { try SDL.initialize(subSystems: [.video]) }
    catch { fatalError("Could not initialize SDL: \(error)") }
    
    defer { SDL.quit() }
    
    let delegate = UIApplication.shared.delegate!
    
    // create main UIScreen
    let screen = try! UIScreen()
    UIScreen._main = screen
	
	let options = _UIApp.options;
	
	let launchOptions = [UIApplicationLaunchOptionsKey: Any]();
	
	let framesPerSecond = 60;
    
    guard delegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions),
        delegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
        else { options.log?("Application delegate could not launch app"); return }
    
    assert(screen.keyWindow?.windowController?.rootViewController != nil, "Application windows are expected to have a root view controller at the end of application launch")
    
    defer { delegate.applicationWillTerminate(UIApplication.shared) }
    
    let eventFetcher = UIApplication.shared.eventFetcher
    
    // enter main loop
    let runloop = RunLoop.current
    
    typealias SDLTimeMS = UInt32
    
    let expectedLoopTime = SDLTimeMS(1000 / framesPerSecond)
    
    // run until app is finished
    while _UIApp.isDone == false {
        
        let startTime = SDL_GetTicks()
        
        // poll events (should never block)
        let eventCount = eventFetcher.pollEvents()
        
        if eventCount > 0 {
            
            print("Polled \(eventCount) events (\(SDL_GetTicks() - startTime)ms)")
        }
        
        // run loop
        let runLoopStartTime = SDL_GetTicks()
        runloop.run(mode: .defaultRunLoopMode, before: Date() + (1.0 / TimeInterval(framesPerSecond)))
        //_UIApp.eventDispatcher.handleHIDEventFetcherDrain()
        if eventCount > 0 { print("Runloop took (\(SDL_GetTicks() - runLoopStartTime)ms)") }
        
        // render to screen
        do { try screen.update() }
        catch { fatalError("Could not render: \(error)") }
        
        // sleep to save energy
        let frameDuration = SDL_GetTicks() - startTime
        
        if frameDuration < expectedLoopTime {
            
            SDL_Delay(expectedLoopTime - frameDuration)
        }
    }
}
