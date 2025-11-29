import { useState, useEffect } from "react";
import "./App.css";
import { isEnvBrowser } from "./utils/misc";
import { responsive } from "./utils/responsive";
import {
	Badge,
	Group,
	Transition,
	Text,
	Button,
	Divider,
	SimpleGrid,
	Title,
	Modal,
	ScrollArea,
	Box,
} from "@mantine/core";
import { useNuiEvent } from "./hooks/useNuiEvent";
import {
	IconPlayerPlay,
	IconPlus,
	IconTrash,
	IconUsersGroup,
} from "@tabler/icons-react";
import InfoCard from "./components/InfoCard";
import { fetchNui } from "./utils/fetchNui";
import { useDisclosure } from "@mantine/hooks";
import CreateCharacterModal from "./components/CreateCharacterModal";
import { modals } from "@mantine/modals";

type CharacterMetadata = Array<{ key: string; value: string }>;

interface Character {
	citizenid: string;
	name: string;
	metadata: CharacterMetadata;
	cid: number;
}

const DEBUG_CHARACTERS: Character[] = [
	{
		citizenid: "Whatever",
		name: "John Doe The Third",
		metadata: [
			{
				key: "job",
				value: "Police",
			},
			{
				key: "nationality",
				value: "German",
			},
			{
				key: "bank",
				value: "100,0000",
			},
			{
				key: "cash",
				value: "430,000",
			},
			{
				key: "birthdate",
				value: "12-10-1899",
			},
			{
				key: "gender",
				value: "Male",
			},
		],
		cid: 1,
	},
	{
		citizenid: "Whatever12",
		name: "Jenna Doe",
		metadata: [
			{
				key: "job",
				value: "Police",
			},
			{
				key: "nationality",
				value: "American",
			},
			{
				key: "bank",
				value: "100,0000",
			},
			{
				key: "cash",
				value: "430,000",
			},
			{
				key: "birthdate",
				value: "12-10-1899",
			},
			{
				key: "gender",
				value: "Male",
			},
		],
		cid: 2,
	},
	{
		citizenid: "HEllo",
		name: "Bax",
		metadata: [
			{
				key: "job",
				value: "Police",
			},
			{
				key: "nationality",
				value: "American",
			},
			{
				key: "bank",
				value: "100,0000",
			},
			{
				key: "cash",
				value: "430,000",
			},
			{
				key: "birthdate",
				value: "12-10-1899",
			},
			{
				key: "gender",
				value: "Male",
			},
		],
		cid: 3,
	},
	{
		citizenid: "Hello123",
		name: "Jake Long",
		metadata: [
			{
				key: "job",
				value: "Police",
			},
			{
				key: "nationality",
				value: "American",
			},
			{
				key: "bank",
				value: "100,0000",
			},
			{
				key: "cash",
				value: "430,000",
			},
			{
				key: "birthdate",
				value: "12-10-1899",
			},
			{
				key: "gender",
				value: "Male",
			},
		],
		cid: 3,
	},
];

function App() {
	const [visible, setVisible] = useState(isEnvBrowser() ? true : false);
	const [characters, setCharacters] = useState<Character[]>(
		isEnvBrowser() ? DEBUG_CHARACTERS : []
	);
	const [isSelected, setIsSelected] = useState(-1);
	const [createCharacterId, setCreateCharacterId] = useState(-1);
	const [opened, { open, close }] = useDisclosure(false);
	const [allowedCharacters, setAllowedCharacters] = useState(
		isEnvBrowser() ? 3 : 0
	);

	// Initialize responsive system
	useEffect(() => {
		// The responsive system is automatically initialized
		// This effect ensures the CSS variables are set on mount
		const updateResponsive = () => {
			// Force a responsive update
			responsive.getConfig();
		};
		
		updateResponsive();
		window.addEventListener('resize', updateResponsive);
		
		return () => {
			window.removeEventListener('resize', updateResponsive);
		};
	}, []);

	useNuiEvent<{ characters: Character[]; allowedCharacters: number }>(
		"showMultiChar",
		(data) => {
			setCharacters(data.characters);
			setAllowedCharacters(data.allowedCharacters);
			setVisible(true);
		}
	);

	const HandleSelect = async (key: number, citizenid: string) => {
		await fetchNui<number>(
			"selectCharacter",
			{ citizenid: citizenid },
			{ data: 1 }
		);
		setIsSelected(key);
	};

	const HandlePlay = async (citizenid: string) => {
		setVisible(false);
		setCharacters([]);
		setIsSelected(-1);
		await fetchNui<number>(
			"playCharacter",
			{ citizenid: citizenid },
			{ data: 1 }
		);
	};

	const HandleDelete = async (citizenid: string) => {
		setVisible(false);
		setCharacters([]);
		setIsSelected(-1);
		await fetchNui<number>(
			"deleteCharacter",
			{ citizenid: citizenid },
			{ data: 1 }
		);
	};

	const HandleCreate = () => {
		close();
		setVisible(false);
		setCharacters([]);
		setIsSelected(-1);
	};

	const openDeleteModal = (citizenid: string) =>
		modals.openConfirmModal({
			title: "Delete Character",
			centered: true,
			children: (
				<Text size='sm' c="var(--text-dimmed)">
					Are you sure you want to permanently delete this character? This action cannot be undone.
				</Text>
			),
			labels: { confirm: "Delete Character", cancel: "Cancel" },
			confirmProps: { 
				color: "red",
				style: {
					background: 'rgba(250, 82, 82, 0.15)',
					border: '1px solid rgba(250, 82, 82, 0.3)',
					color: 'var(--red-primary)'
				}
			},
			cancelProps: {
				style: {
					background: 'rgba(255, 255, 255, 0.1)',
					border: '1px solid rgba(255, 255, 255, 0.2)',
					color: 'var(--text-primary)'
				}
			},
			onCancel: () => console.log("Cancel"),
			onConfirm: () => HandleDelete(citizenid),
		});

	return (
		<>
			<Modal
				opened={opened}
				onClose={close}
				title={`Create Character ${createCharacterId + 1}`}
				centered
				overlayProps={{
					backgroundOpacity: 0.55,
					blur: 3,
				}}
				styles={{
					content: {
						background: 'var(--secondary-bg)',
						border: '1px solid rgba(255, 255, 255, 0.1)',
						borderRadius: 'calc(12px * var(--scale-factor))',
					},
					title: {
						color: 'var(--text-primary)',
						fontWeight: 600,
						textShadow: '0 0 calc(5px * var(--scale-factor)) var(--blue-primary)',
					}
				}}
			>
				<CreateCharacterModal
					id={createCharacterId + 1}
					handleCreate={HandleCreate}
				/>
			</Modal>

			<div className={`app-container`}>
				{/* Logo watermark in bottom left */}
				{visible && (
					<img 
						src="https://r2.fivemanage.com/aOkIPeZksXD3I7JXuvAsG/LogoLetter.png"
						alt="HOF Logo"
						style={{
							position: 'fixed',
							bottom: responsive.scaleVh(20),
							left: responsive.scaleVh(20),
							width: responsive.scaleVh(48),
							height: responsive.scaleVh(48),
							opacity: 0.6,
							filter: `drop-shadow(0 0 ${responsive.scaleVh(5)} var(--blue-primary))`,
							transition: 'all 0.3s ease-out',
							zIndex: 10,
							pointerEvents: 'none'
						}}
						onError={(e) => {
							// Fallback if image fails to load
							e.currentTarget.style.display = 'none';
						}}
					/>
				)}
				
				<Box className='container'>
					{visible && (
						<div className='character-selector-top'>
							<IconUsersGroup 
								size={responsive.scaleVh(35)} 
								color='var(--blue-primary)' 
								style={{
									filter: `drop-shadow(0 0 ${responsive.scaleVh(10)} var(--blue-primary))`
								}}
							/>
							<Title 
								order={2} 
								size={responsive.scaleVh(24)} 
								c="var(--text-primary)"
								className="text-glow-blue"
							>
								Character Selector
							</Title>
							<Text 
								fw={500} 
								size={responsive.scaleVh(12)} 
								c="var(--text-dimmed)"
							>
								Select the character you want to play
							</Text>
						</div>
					)}

					<Transition 
						transition={{
							in: { opacity: 1, transform: 'translateY(0)' },
							out: { opacity: 0, transform: 'translateY(20px)' },
							transitionProperty: 'opacity, transform',
						}} 
						mounted={visible}
						duration={300}
					>
						{(style) => (
							<ScrollArea 
								style={{ 
									...style,
									maxHeight: '70vh',
									width: '100%'
								}}
							>
								<div className='multichar'>
									{[...Array(allowedCharacters)].map((_, index) => {
										const character = characters[index];
										return character ? (
											<div className='character-card smooth-transition' key={character.citizenid}>
												<Group justify='space-between'>
													<Text fw={600} size={responsive.scaleVh(14)} c="var(--text-primary)">
														{character.name}
													</Text>
													<Badge
														variant='light'
														radius='sm'
														styles={{
															root: {
																background: 'rgba(34, 139, 230, 0.2)',
																color: 'var(--blue-primary)',
																border: '1px solid rgba(34, 139, 230, 0.3)',
																textShadow: '0 0 calc(5px * var(--scale-factor)) var(--blue-primary)'
															}
														}}
													>
														{character.citizenid}
													</Badge>
												</Group>

												<div
													className={
														isSelected === character.cid ? "show" : "hide"
													}
												>
													<SimpleGrid cols={2} spacing={responsive.scaleVh(4)}>
														{character.metadata &&
															character.metadata.length > 0 &&
															character.metadata.map((metadata) => (
																<InfoCard
																	key={metadata.key}
																	icon={metadata.key}
																	label={metadata.value}
																/>
															))}
													</SimpleGrid>

													<Divider 
														color='rgba(255, 255, 255, 0.1)' 
														styles={{
															root: {
																margin: `${responsive.scaleVh(4)} 0`
															}
														}}
													/>

													<div className='character-card-actions'>
														<Button
															color='green'
															variant='light'
															fullWidth
															leftSection={<IconPlayerPlay size={responsive.scaleVh(10)} />}
															h={responsive.scaleVh(28)}
															onClick={() => {
																HandlePlay(character.citizenid);
															}}
															styles={{
																root: {
																	background: 'rgba(81, 207, 102, 0.15)',
																	color: 'var(--green-primary)',
																	border: '1px solid rgba(81, 207, 102, 0.3)',
																	borderRadius: 'calc(6px * var(--scale-factor))',
																	fontWeight: 600,
																	fontSize: 'calc(11px * var(--scale-factor))',
																	transition: 'all 0.3s ease-out',
																	'&:hover': {
																		background: 'rgba(81, 207, 102, 0.25)',
																		transform: 'translateY(-1px)',
																		boxShadow: '0 0 calc(10px * var(--scale-factor)) rgba(81, 207, 102, 0.4)'
																	}
																}
															}}
														>
															Play
														</Button>

														<Button
															color='red'
															variant='light'
															fullWidth
															leftSection={<IconTrash size={responsive.scaleVh(10)} />}
															h={responsive.scaleVh(28)}
															onClick={() => {
																openDeleteModal(character.citizenid);
															}}
															styles={{
																root: {
																	background: 'rgba(250, 82, 82, 0.15)',
																	color: 'var(--red-primary)',
																	border: '1px solid rgba(250, 82, 82, 0.3)',
																	borderRadius: 'calc(6px * var(--scale-factor))',
																	fontWeight: 600,
																	fontSize: 'calc(11px * var(--scale-factor))',
																	transition: 'all 0.3s ease-out',
																	'&:hover': {
																		background: 'rgba(250, 82, 82, 0.25)',
																		transform: 'translateY(-1px)',
																		boxShadow: '0 0 calc(10px * var(--scale-factor)) rgba(250, 82, 82, 0.4)'
																	}
																}
															}}
														>
															Delete
														</Button>
													</div>
												</div>

												<div
													className={
														isSelected === character.cid ? "hide" : "show"
													}
												>
													<Button
														color='blue'
														variant='light'
														fullWidth
														h={responsive.scaleVh(28)}
														onClick={() => {
															HandleSelect(character.cid, character.citizenid);
														}}
														styles={{
															root: {
																background: 'rgba(34, 139, 230, 0.15)',
																color: 'var(--blue-primary)',
																border: '1px solid rgba(34, 139, 230, 0.3)',
																borderRadius: 'calc(6px * var(--scale-factor))',
																fontWeight: 600,
																fontSize: 'calc(11px * var(--scale-factor))',
																transition: 'all 0.3s ease-out',
																'&:hover': {
																	background: 'rgba(34, 139, 230, 0.25)',
																	transform: 'translateY(-1px)',
																	boxShadow: '0 0 calc(10px * var(--scale-factor)) rgba(34, 139, 230, 0.4)'
																}
															}
														}}
													>
														Select
													</Button>
												</div>
											</div>
										) : (
											<div
												className='character-card create-card smooth-transition'
												key={`create-${index}`}
											>
												<Button
													color='blue'
													variant='light'
													fullWidth
													leftSection={<IconPlus size={responsive.scaleVh(16)} />}
													onClick={() => {
														open();
														setCreateCharacterId(index);
													}}
													styles={{
														root: {
															background: 'rgba(34, 139, 230, 0.15)',
															color: 'var(--blue-primary)',
															border: '1px solid rgba(34, 139, 230, 0.3)',
															borderRadius: 'calc(6px * var(--scale-factor))',
															fontWeight: 600,
															fontSize: 'calc(12px * var(--scale-factor))',
															padding: 'calc(10px * var(--scale-factor)) calc(15px * var(--scale-factor))',
															height: responsive.scaleVh(40),
															transition: 'all 0.3s ease-out',
															'&:hover': {
																background: 'rgba(34, 139, 230, 0.25)',
																transform: 'scale(1.02)',
																boxShadow: '0 0 calc(15px * var(--scale-factor)) rgba(34, 139, 230, 0.4)'
															}
														}
													}}
												>
													Create New Character
												</Button>
											</div>
										);
									})}
								</div>
							</ScrollArea>
						)}
					</Transition>
				</Box>
			</div>
		</>
	);
}

export default App;
