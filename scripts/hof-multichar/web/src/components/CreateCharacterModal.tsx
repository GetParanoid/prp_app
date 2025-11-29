import React from "react";
import { Button, Group, Select, TextInput, Stack, Text, Divider, Box } from "@mantine/core";
import { useForm } from "@mantine/form";
import { DatePickerInput } from "@mantine/dates";
import { IconCalendar, IconUser, IconFlag, IconGenderBigender, IconUsers } from "@tabler/icons-react";
import { fetchNui } from "../utils/fetchNui";
import { responsive } from "../utils/responsive";

interface Props {
	handleCreate: () => void;
	id: number;
}

const CreateCharacterModal: React.FC<Props> = (props) => {
	const form = useForm({
		initialValues: {
			firstName: "",
			lastName: "",
			nationality: "",
			gender: "",
			birthdate: new Date("2006-12-31"),
		},
		validate: {
			firstName: (value) => value.length < 2 ? 'First name must be at least 2 characters' : null,
			lastName: (value) => value.length < 2 ? 'Last name must be at least 2 characters' : null,
			nationality: (value) => value.length < 2 ? 'Nationality must be at least 2 characters' : null,
			gender: (value) => !value ? 'Please select a gender' : null,
		},
	});

	const handleSubmit = async (values: {
		firstName: string;
		lastName: string;
		nationality: string;
		gender: string;
		birthdate: Date;
	}) => {
		const dateString = values.birthdate.toISOString().slice(0, 10);
		props.handleCreate();
		await fetchNui<string>(
			"createCharacter",
			{ cid: props.id, character: { ...values, birthdate: dateString } },
			{ data: "success" }
		);
	};

	const inputStyles = {
		input: {
			background: 'linear-gradient(145deg, var(--surface-bg) 0%, rgba(44, 46, 51, 0.8) 100%)',
			border: '1px solid rgba(255, 255, 255, 0.1)',
			color: 'var(--text-primary)',
			borderRadius: 'calc(6px * var(--scale-factor))',
			fontSize: `calc(14px * var(--scale-factor))`,
			padding: `calc(8px * var(--scale-factor)) calc(12px * var(--scale-factor))`,
			backdropFilter: 'blur(5px)',
			transition: 'all 0.3s ease-out',
			'&:focus': {
				borderColor: 'var(--blue-primary)',
				boxShadow: '0 0 calc(8px * var(--scale-factor)) rgba(34, 139, 230, 0.3)',
				background: 'linear-gradient(145deg, rgba(44, 46, 51, 0.9) 0%, var(--surface-bg) 100%)',
			},
			'&::placeholder': {
				color: 'var(--text-dimmed)',
				opacity: 0.7
			}
		},
		label: {
			color: 'var(--text-primary)',
			fontWeight: 500,
			fontSize: `calc(12px * var(--scale-factor))`,
			marginBottom: `calc(4px * var(--scale-factor))`,
		}
	};

	return (
		<Box style={{ padding: `calc(5px * var(--scale-factor))` }}>
			{/* Header Section */}
			<Box style={{ 
				textAlign: 'center', 
				marginBottom: `calc(15px * var(--scale-factor))`,
				padding: `calc(10px * var(--scale-factor))`,
				background: 'linear-gradient(135deg, rgba(34, 139, 230, 0.1) 0%, rgba(34, 139, 230, 0.05) 100%)',
				borderRadius: `calc(6px * var(--scale-factor))`,
				border: '1px solid rgba(34, 139, 230, 0.2)'
			}}>
				<IconUsers 
					size={responsive.scaleVh(24)} 
					color='var(--blue-primary)'
					style={{
						marginBottom: `calc(4px * var(--scale-factor))`,
						filter: `drop-shadow(0 0 ${responsive.scaleVh(6)} var(--blue-primary))`
					}}
				/>
				<Text 
					size={responsive.scaleVh(16)} 
					fw={600} 
					c="var(--text-primary)"
					style={{
						textShadow: '0 0 calc(6px * var(--scale-factor)) var(--blue-primary)',
					}}
				>
					Character Slot {props.id}
				</Text>
				<Text 
					size={responsive.scaleVh(11)} 
					c="var(--text-dimmed)"
					style={{ marginTop: `calc(2px * var(--scale-factor))` }}
				>
					Create your new character identity
				</Text>
			</Box>

			<form onSubmit={form.onSubmit((values) => handleSubmit(values))}>
				<Stack gap={responsive.scaleVh(12)}>
					{/* Name Section */}
					<Box>
						<Text 
							size={responsive.scaleVh(12)} 
							fw={600} 
							c="var(--blue-primary)"
							style={{ 
								marginBottom: `calc(8px * var(--scale-factor))`,
								display: 'flex',
								alignItems: 'center',
								gap: `calc(4px * var(--scale-factor))`
							}}
						>
							<IconUser size={responsive.scaleVh(14)} />
							Personal Information
						</Text>
						<Group grow>
							<TextInput
								data-autofocus
								required
								placeholder='Enter first name'
								label='First Name'
								styles={inputStyles}
								{...form.getInputProps("firstName")}
							/>
							<TextInput
								required
								placeholder='Enter last name'
								label='Last Name'
								styles={inputStyles}
								{...form.getInputProps("lastName")}
							/>
						</Group>
					</Box>

					<Divider 
						color="rgba(255, 255, 255, 0.1)" 
						style={{ margin: `calc(2px * var(--scale-factor)) 0` }} 
					/>

					{/* Demographics Section */}
					<Box>
						<Text 
							size={responsive.scaleVh(12)} 
							fw={600} 
							c="var(--cyan-primary)"
							style={{ 
								marginBottom: `calc(8px * var(--scale-factor))`,
								display: 'flex',
								alignItems: 'center',
								gap: `calc(4px * var(--scale-factor))`
							}}
						>
							<IconFlag size={responsive.scaleVh(14)} />
							Demographics
						</Text>
						<Group grow>
							<TextInput
								required
								placeholder='Enter nationality'
								label='Nationality'
								styles={inputStyles}
								{...form.getInputProps("nationality")}
							/>
							<Select
								required
								label='Gender'
								placeholder='Select gender'
								data={[
									{ value: "Male", label: "Male" },
									{ value: "Female", label: "Female" }
								]}
								defaultValue='Male'
								allowDeselect={false}
								leftSection={<IconGenderBigender size={responsive.scaleVh(14)} color="var(--cyan-primary)" />}
								leftSectionPointerEvents='none'
								leftSectionWidth={42}
								comboboxProps={{
									styles: {
										dropdown: {
											background: 'var(--secondary-bg)',
											border: '1px solid rgba(255, 255, 255, 0.1)',
											borderRadius: `calc(6px * var(--scale-factor))`,
											backdropFilter: 'blur(10px)',
											colorScheme: 'dark'
										},
										option: {
											color: 'var(--text-primary)',
											'&[data-selected]': {
												background: 'rgba(34, 139, 230, 0.2)',
												color: 'var(--blue-primary)'
											},
											'&:hover': {
												background: 'rgba(255, 255, 255, 0.1)'
											}
										}
									}
								}}
								styles={{
									...inputStyles,
									input: {
										...inputStyles.input,
										paddingLeft: `calc(45px * var(--scale-factor))`,
									}
								}}
								{...form.getInputProps("gender")}
							/>
						</Group>
					</Box>

					<Divider 
						color="rgba(255, 255, 255, 0.1)" 
						style={{ margin: `calc(2px * var(--scale-factor)) 0` }} 
					/>

					{/* Birth Information */}
					<Box>
						<Text 
							size={responsive.scaleVh(12)} 
							fw={600} 
							c="var(--yellow-primary)"
							style={{ 
								marginBottom: `calc(8px * var(--scale-factor))`,
								display: 'flex',
								alignItems: 'center',
								gap: `calc(4px * var(--scale-factor))`
							}}
						>
							<IconCalendar size={responsive.scaleVh(14)} />
							Birth Information
						</Text>
						<DatePickerInput
							leftSection={
								<IconCalendar 
									size={responsive.scaleVh(14)} 
									color='var(--yellow-primary)'
								/>
							}
							leftSectionPointerEvents='none'
							leftSectionWidth={42}
							label='Birth Date'
							placeholder="Select birth date"
							valueFormat='YYYY-MM-DD'
							defaultValue={new Date("2006-12-31")}
							minDate={new Date("1900-01-01")}
							maxDate={new Date("2006-12-31")}
							popoverProps={{
								styles: {
									dropdown: {
										background: 'var(--secondary-bg)',
										border: '1px solid rgba(255, 255, 255, 0.1)',
										borderRadius: `calc(6px * var(--scale-factor))`,
										backdropFilter: 'blur(10px)',
										color: 'var(--text-primary)',
										// Calendar container
										'& .mantine-Calendar-calendar': {
											background: 'transparent',
											color: 'var(--text-primary)'
										},
										// Individual days
										'& .mantine-Calendar-day': {
											color: 'var(--text-primary)',
											'&:hover': {
												background: 'rgba(255, 255, 255, 0.1)',
												color: 'var(--text-primary)'
											},
											'&[data-selected]': {
												background: 'var(--blue-primary)',
												color: 'white'
											},
											'&[data-weekend]': {
												color: 'var(--text-secondary)'
											}
										},
										// Calendar header (month/year display)
										'& .mantine-Calendar-calendarHeader': {
											color: 'var(--text-primary)'
										},
										// Header controls (clickable month/year text)
										'& .mantine-Calendar-calendarHeaderControl, & .mantine-Calendar-calendarHeaderLevel': {
											color: 'var(--text-primary) !important',
											backgroundColor: 'transparent !important',
											'&:hover': {
												background: 'var(--blue-primary) !important',
												color: 'white !important'
											}
										},
										// Month picker controls (individual months)
										'& .mantine-MonthPicker-monthPickerControl, & .mantine-MonthPicker-control, & .mantine-MonthPicker-pickerControl': {
											color: 'var(--text-primary) !important',
											backgroundColor: 'transparent !important',
											'&:hover': {
												background: 'var(--blue-primary) !important',
												color: 'white !important'
											}
										},
										// Year picker controls (individual years)
										'& .mantine-YearPicker-yearPickerControl, & .mantine-YearPicker-control, & .mantine-YearPicker-pickerControl': {
											color: 'var(--text-primary) !important',
											backgroundColor: 'transparent !important',
											'&:hover': {
												background: 'var(--blue-primary) !important',
												color: 'white !important'
											}
										},
										// Decade picker controls
										'& .mantine-DecadePicker-decadePickerControl, & .mantine-DecadePicker-control, & .mantine-DecadePicker-pickerControl': {
											color: 'var(--text-primary) !important',
											backgroundColor: 'transparent !important',
											'&:hover': {
												background: 'var(--blue-primary) !important',
												color: 'white !important'
											}
										},
										// Generic picker controls (catch-all)
										'& [data-mantine-color-scheme] button, & button': {
											color: 'var(--text-primary) !important',
											'&:hover:not([data-selected])': {
												background: 'var(--blue-primary) !important',
												color: 'white !important'
											}
										}
									}
								}
							}}
							styles={{
								...inputStyles,
								input: {
									...inputStyles.input,
									paddingLeft: `calc(45px * var(--scale-factor))`,
								}
							}}
							{...form.getInputProps("birthdate")}
						/>
					</Box>

					{/* Action Buttons */}
					<Group justify='flex-end' mt={responsive.scaleVh(15)} gap={responsive.scaleVh(8)}>
						<Button 
							variant='subtle'
							color='gray'
							onClick={() => form.reset()}
							size="sm"
							style={{
								background: 'rgba(255, 255, 255, 0.1)',
								color: 'var(--text-dimmed)',
								border: '1px solid rgba(255, 255, 255, 0.2)',
								borderRadius: 'calc(6px * var(--scale-factor))',
								fontWeight: 500,
								fontSize: `calc(12px * var(--scale-factor))`,
								height: 'auto',
								padding: `calc(8px * var(--scale-factor)) calc(16px * var(--scale-factor))`,
							}}
						>
							Reset
						</Button>
						<Button 
							type='submit'
							size="sm"
							style={{
								background: 'linear-gradient(135deg, rgba(81, 207, 102, 0.2) 0%, rgba(81, 207, 102, 0.1) 100%)',
								color: 'var(--green-primary)',
								border: '1px solid rgba(81, 207, 102, 0.4)',
								borderRadius: 'calc(6px * var(--scale-factor))',
								fontWeight: 600,
								fontSize: `calc(12px * var(--scale-factor))`,
								height: 'auto',
								padding: `calc(8px * var(--scale-factor)) calc(20px * var(--scale-factor))`,
								transition: 'all 0.3s ease-out',
							}}
						>
							Create Character
						</Button>
					</Group>
				</Stack>
			</form>
		</Box>
	);
};

export default CreateCharacterModal;
